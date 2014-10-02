%% The idea of the database AI is to randomly choose positions to shoot at
%% until a hit is found, when a hit is found, it tries to shoot in surrounding
%% squares until the ship is sunk. Then it begins to shoot at random places.

:- use_module(library(random)).

debug_board([[~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,h,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~]]).

test_me :-
    debug_board(X),
    first_occurrence_of(h, X, Y),
    write(Y).

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

%% Interface for other modules to use, given a board, returns
%% the choice of the AI.
%% FIXME: Needs implementation
ai_choice(Board, [ShotX, ShotY]) :-
    needs_implementation.
