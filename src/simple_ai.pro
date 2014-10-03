%% The idea of the database AI is to randomly choose positions to shoot at
%% until a hit is found, when a hit is found, it tries to shoot in surrounding
%% squares until the ship is sunk. Then it begins to shoot at random places.

:- use_module(library(random)).

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
    write(Y),
    nl,
    look_at(Board, {4,5}, Elem),
    write('element is:'),
    nl,
    write(Elem),
    nl,
    exhausted(Board, {4,4}, IsExhausted),
    write(IsExhausted).

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

%% the new coordinate is not exhausted
smart_pick(Board, Coordinate, NewCoordinate) :-
    write('BEFORE'),
    exhausted(Board, Coordinate, false),
    write('AFTER'),
    {X, Y} = Coordinate,
    Up    is Y - 1,
    Down  is Y + 1,
    Left  is X - 1,
    Right is X + 1,
    look_at(Board, {X, Up}, RespUp),
   (RespUp == '~' ->
      NewCoordinate = {X, Up}
   ;
      look_at(Board, {Left, Y}, RespLeft),
      (RespLeft == '~' ->
           NewCoordinate = {Left, Y}
       ;
           look_at(Board, {X, Down}, RespDown),
           (RespDown == '~' ->
               NewCoordinate = {X, Down}
           ;
               NewCoordinate = {Right, Y}
           )
      )
   ).
% in this clause, we are in an exhausted square:
smart_pick(Board, Coordinate, NewCoordinate) :-
    write('ALTERNATIVE'),
    {X, Y} = Coordinate,
    Up    is Y - 1,
    Down  is Y + 1,
    Left  is X - 1,
    Right is X + 1,
    look_at(Board, {X, Up}, RespUp),
    write('opop1'),
    (RespUp == 'h' ->
        NewCoordinate = {X, Up}
    ;
        look_at(Board, {Left, Y}, RespLeft),
        (RespLeft == 'h' ->
            NewCoordinate = {Left, Y}
        ;
            look_at(Board, {X, Down}, RespDown),
            (RespDown == 'h' ->
                NewCoordinate = {X, Down}
            ;
                NewCoordinate = {Right, Y}
            )
        )
    ).

%% FIXME: this can now return missed squares,
%%        hit squares or sunk squares, preferrably it
%%        should only return water tiles.
shoot_water(Board, ShootAtCoord) :-
    write('SHOOOOT WATER!!!'),
    nl,
    first_occurrence_of('~', Board, FirstW),
    nl,
    write('nu:'),
    write(FirstW),
    (FirstW == no_elem ->
        write('no elem!!!'),
        %% Now, there is no more water left to shoot at,
        %% so lets shoot at [0,0]
        ShootAtCoord = [0,0]
    ;
        ShootAtCoord = FirstW
    ).

% keep calling smart_pick until we have a not exhausted coordinate
it_smart_pick(Board, Coordinate, NewCoordinate) :-
    write('smart pick IT'),
    nl,
    smart_pick(Board, Coordinate, Result),
    write('NEVER COMES HERE'),
    exhausted(Board, Result, IsExhausted),
    %% The coodinate picked is exhausted:
    (IsExhausted == true ->
        write('EXHAUSTED'),
        is_smart_pick(Board, Result, NewCoordinate)
    ;
    %% The cordinate picked is NOT exhausted:
        look_at(Board, Result, Value),
        (Value == h ->
            write('first scenario'),
            nl,
            % if h we should return something surrounding which is not h
            smart_pick(Board, Result, Round2),
            NewCoordinate = Round2
        ;
            write('coming here'),
            write(Result),
            nl,
            NewCoordinate = Result
        )
    ).

%% Interface for other modules to use, given a board, returns
%% the choice of the AI.
ai_choice(Board, GiveBack) :-
    first_occurrence_of(h, Board, FirstH),
    write('hello'),
    (FirstH == no_elem ->
        % do random picking which is not already shot
        nl,
        write('water!!'),
        shoot_water(Board, GiveBack),
        nl,
        write('water ooooook'),
        nl
     ;
        write('Simple ai: h found, look at surrounding places'),
        % Smart_hit gives a coord that is not exhausted
        it_smart_pick(Board, FirstH, GiveBack)
    ).
