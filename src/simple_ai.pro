:- use_module(library(random)).

%% The idea of the database AI is to randomly choose positions to shoot at
%% until a hit is found, when a hit is found, it tries to shoot in surrounding
%% squares until the ship is sunk. Then it begins to shoot at random places.



debug_board([[~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~]]).

test_me :-
    debug_board(Board),
    first_occurrence_of(h, Board, Y),
    look_at(Board, {4,5}, Elem),
    exhausted(Board, {4,4}, IsExhausted),
    write(IsExhausted).

test_water :-
    debug_board(Board),
    first_occurrence_of(~, Board, X),
    write(X).

%% The element we look for is the head of row, return counter :)
occurence_in_row(_,       [],              _,         no_elem).
occurence_in_row(LookFor, [LookFor|Elems], Counter,   Counter).
occurence_in_row(LookFor, [Elem   |Elems], CounterIn, CounterOut) :-
    NewCounter is CounterIn + 1,
    occurence_in_row(LookFor, Elems, NewCounter, CounterOut).

%% Given something to search for and a board, either return the coordinate
%% matching whatever to look for, or return no (prolog no answer)
%% [Row|Rows] is the board
occurence_in_board(LookFor, []        , _,         no_elem).
occurence_in_board(LookFor, [Row|Rows], CounterIn, CounterOut) :-
    occurence_in_row(LookFor, Row, 0, ColNum),
    (ColNum == no_elem ->
        NewCounter is CounterIn + 1,
        occurence_in_board(LookFor, Rows, NewCounter, CounterOut)
    ;
        CounterOut = {ColNum, CounterIn}
    ).

%% first_occurence_of takes a Board and a value to look for
%% (such as h, m, s), then returns the first coordinate which
%% holds such a value.
first_occurrence_of(LookFor, Board, ReturnCoordinate) :-
    occurence_in_board(LookFor, Board, 0, ReturnCoordinate).

look_at(Board, {X,Y}, Value) :-
    look_at_board(Board, {X,Y}, Y, Value).

look_at_board([Row|Rows], {X,Y}, 0, Value) :-
    look_at_row(Row, X, Value).

look_at_board([Row|Rows], {X,Y}, RowCounter, Value) :-
    NextRowCounter is RowCounter - 1,
    look_at_board(Rows, {X,Y}, NextRowCounter, Value).

look_at_row([Head|Tail], 0, Head).
look_at_row([Head|Tail], X, Element) :-
    NextX is X - 1,
    look_at_row(Tail, NextX, Element).

exhausted(Board, {X, Y}, Response) :-
    Up    is Y - 1,
    Down  is Y + 1,
    Left  is X - 1,
    Right is X + 1,
    look_at(Board, {X,     Up},   Resp1),
    look_at(Board, {X,     Down}, Resp2),
    look_at(Board, {Left,  Y},    Resp3),
    look_at(Board, {Right, Y},    Resp4),
    ((Resp1 \= '~', Resp2 \= '~', Resp3 \= '~', Resp4 \= '~') ->
        Response = true
    ;
        Response = false
    ).

%% Lifting away the previous 4 level if statement to pattern matching
smart_pick_help({X, _Y}, Match, [{Match, Up}, _, _, _],    {X, Up}).
smart_pick_help({_X, Y}, Match, [_, {Match, Left}, _, _],  {Left, Y}).
smart_pick_help({X, _Y}, Match, [_, _, {Match, Down}, _],  {X, Down}).
smart_pick_help({_X, Y}, Match, [_, _, _, {Match, Right}], {Right, Y}).

%% the new coordinate is not exhausted
%% {X, Y} is Coordinate
smart_pick(Board, {X, Y}, NewCoordinate) :-
    exhausted(Board, {X, Y}, false),
    Up    is Y - 1,
    Down  is Y + 1,
    Left  is X - 1,
    Right is X + 1,
    look_at(Board, {X, Up},    RespUp),
    look_at(Board, {Left, Y},  RespLeft),
    look_at(Board, {X, Down},  RespDown),
    look_at(Board, {Right, Y}, RespRight),
    smart_pick_help({X, Y},
                    '~',
                    [{RespUp, Up}, {RespLeft, Left},
                     {RespDown, Down}, {RespRight, Right}],
                    NewCoordinate).
					
					
% in this clause, we are in an exhausted square:
smart_pick(Board, {X, Y}, NewCoordinate) :-
    Up    is Y - 1,
    Down  is Y + 1,
    Left  is X - 1,
    Right is X + 1,
    look_at(Board, {X, Up},    RespUp),
    look_at(Board, {Left, Y},  RespLeft),
    look_at(Board, {X, Down},  RespDown),
    look_at(Board, {Right, Y}, RespRight),
    smart_pick_help({X, Y},
                    'h',
                    [{RespUp, Up}, {RespLeft, Left},
                     {RespDown, Down}, {RespRight, Right}],
                    NewCoordinate).

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
    exhausted(Board, Result, IsExhausted),
	
    %% The coodinate picked is exhausted:
    (IsExhausted == true ->
        it_smart_pick(Board, Result, NewCoordinate)
    ;
		%% The cordinate picked is NOT exhausted:
        look_at(Board, Result, Value),
        (Value == h ->
            % if h we should return something surrounding which is not h
            smart_pick(Board, Result, Round2),
            NewCoordinate = Round2
        ;
            NewCoordinate = Result
        )
    ).

%% Interface for other modules to use, given a board, returns
%% the choice of the AI.
ai_choice(Board, GiveBack) :-
	
    first_occurrence_of(h, Board, FirstH),
    (FirstH == no_elem ->
        % do random picking which is not already shot
        do_random(Board, GiveBack)
     ;
        % Smart_hit gives a coord that is not exhausted
        it_smart_pick(Board, FirstH, {X, Y}),
        GiveBack = [X, Y]
    ).
	
