:- use_module(library(random)).

%% The idea of the database AI is to randomly choose positions to shoot at
%% until a hit is found, when a hit is found, it tries to shoot in surrounding
%% squares until the ship is sunk. Then it begins to shoot at random places.

%% The element we look for is the head of row, return counter :)
occurrence_in_row(LookFor, [LookFor|_Elems], Counter,   Counter).
occurrence_in_row(LookFor, [_Elem  |Elems], CounterIn, CounterOut) :-
    NewCounter is CounterIn + 1,
    occurrence_in_row(LookFor, Elems, NewCounter, CounterOut).

%% Given something to search for and a board, either return the coordinate
%% matching whatever to look for, or return no (prolog no answer)
%% [Row|Rows] is the board
occurrence_in_board(_LookFor, []        , _,         no_elem).
occurrence_in_board(LookFor,  [Row|_Rows], CounterIn, {ColNum, CounterIn}) :-
    occurrence_in_row(LookFor, Row, 0, ColNum).

occurrence_in_board(LookFor, [_Row|Rows], CounterIn, CounterOut) :-
    NewCounter is CounterIn + 1,
    occurrence_in_board(LookFor, Rows, NewCounter, CounterOut).

%% first_occurence_of takes a Board and a value to look for
%% (such as h, m, s), then returns the first coordinate which
%% holds such a value.
first_occurrence_of(LookFor, Board, ReturnCoordinate) :-
    occurrence_in_board(LookFor, Board, 0, ReturnCoordinate).

look_at(Board, {X,Y}, Value) :-
    look_at_board(Board, {X,Y}, Y, Value).

look_at_board([Row|_Rows], {X,_Y}, 0, Value) :-
    look_at_row(Row, X, Value).

look_at_board([_Row|Rows], {X,Y}, RowCounter, Value) :-
    NextRowCounter is RowCounter - 1,
    look_at_board(Rows, {X,Y}, NextRowCounter, Value).

look_at_row([Head|_Tail], 0, Head).
look_at_row([_Head|Tail], X, Element) :-
    NextX is X - 1,
    look_at_row(Tail, NextX, Element).

look_at_directions(Board, {X, Y}, {RespUp, RespLeft, RespDown, RespRight}) :-
    directions({X, Y}, {Up, Down, Left, Right}),
    look_at(Board, {X, Up},    RespUp),
    look_at(Board, {Left, Y},  RespLeft),
    look_at(Board, {X, Down},  RespDown),
    look_at(Board, {Right, Y}, RespRight).

directions({X, Y}, {Up, Down, Left, Right}) :-
    Up    is Y - 1,
    Down  is Y + 1,
    Left  is X - 1,
    Right is X + 1.

%% a coordinate is exhausted if neither of up, left, down, right are water
exhausted(Board, Coord, true) :-
    look_at_directions(Board, Coord, {Up, Left, Down, Right}),
    Up    \= '~',
    Left  \= '~',
    Down  \= '~',
    Right \= '~'.
exhausted(_, _, false).

out_of_scope({X, Y}, true) :-
    (X < 0, X > 9, Y < 0, Y > 9).
out_of_scope(_, false).

%% Lifting away the previous 4 level if statement to pattern matching
smart_pick_help({X, _Y}, Match, [{Match, Up}, _, _, _],    {X, Up}).
smart_pick_help({_X, Y}, Match, [_, {Match, Left}, _, _],  {Left, Y}).
smart_pick_help({X, _Y}, Match, [_, _, {Match, Down}, _],  {X, Down}).
smart_pick_help({_X, Y}, Match, [_, _, _, {Match, Right}], {Right, Y}).

%% the new coordinate is not exhausted
%% {X, Y} is Coordinate
smart_pick(Board, {X, Y}, NewCoordinate) :-
    exhausted(Board, {X, Y}, false),
    directions({X, Y}, {Up, Down, Left, Right}),
    look_at_directions(Board, {X, Y}, {RUp, RLeft, RDown, RRight}),
    SendList = [{RUp, Up}, {RLeft, Left}, {RDown, Down}, {RRight, Right}],
    smart_pick_help({X, Y}, '~', SendList, NewCoordinate).
% in this clause, we are in an exhausted square:
smart_pick(Board, {X, Y}, NewCoordinate) :-
    directions({X, Y}, {Up, Down, Left, Right}),
    look_at_directions(Board, {X, Y}, {RUp, RLeft, RDown, RRight}),
    SendList = [{RUp, Up}, {RLeft, Left}, {RDown, Down}, {RRight, Right}],
    smart_pick_help({X, Y}, h, SendList, Result),
    out_of_scope(Result, IsOutside),
    (IsOutside == true ->
        first_occurrence_of('~', Board, NewCoordinate)
    ;
        NewCoordinate = Result
    ).

%% Random shot
%% However, we only want to shoot at water... If there is no water left
%% Then we shoot at [0,0]
do_random(Board, [RandX, RandY]) :-
    first_occurrence_of('~', Board, FirstW),
    (FirstW == no_elem ->
        %maybe this is an indication the game ended
        RandX = 0,
        RandY = 0
    ;
        random(0, 9, X),
        random(0, 9, Y),
        look_at(Board, {X,Y}, LookAtResult),
        (LookAtResult == '~' ->
            RandX = X,
            RandY = Y
        ;
            {RandX, RandY} = FirstW
        )
    ).

% keep calling smart_pick until we have a not exhausted coordinate
it_smart_pick(Board, Coordinate, NewCoordinate) :-
    smart_pick(Board, Coordinate, Result),
    %% The coodinate picked is exhausted:
    exhausted(Board, Result, true),
    it_smart_pick(Board, Result, NewCoordinate).

% The coordinate is not exhausted, and we are looking at a 'h':
it_smart_pick(Board, Coordinate, NewCoordinate) :-
    smart_pick(Board, Coordinate, Result),
    %% The cordinate picked is NOT exhausted:
    look_at(Board, Result, h),
    write('Looking for h'),
    smart_pick(Board, Result, NewCoordinate).

% Not exhausted, and not looking at a 'h'
it_smart_pick(Board, Coordinate, NewCoordinate) :-
    smart_pick(Board, Coordinate, NewCoordinate).

%% Interface for other modules to use, given a board, returns
%% the choice of the AI.
ai_choice(Board, GiveBack) :-
    first_occurrence_of(h, Board, FirstH),
    (FirstH == no_elem ->
        do_random(Board, GiveBack)
    ;
        it_smart_pick(Board, FirstH, {X, Y}),
        GiveBack = [X, Y]
    ).
