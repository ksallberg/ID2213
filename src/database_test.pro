%% Testing how to add knowledge to the prolog database runtime.
%% Removing one: retractall(person('herman')).

start :- loop('normal').

loop('exit') :-
    write('printing all persons from the db:'),
    nl,
    findall(X, person(X), ListBefore),
    write(ListBefore),
    nl,
    write('now resetting db'),
    nl,
    retractall(person(_)),
    write('again print all persons from the db:'),
    nl,
    findall(X, person(X), ListAfter),
    write(ListAfter),
    nl.

loop('normal') :-
    write('Add a person to a list of persons, or type exit'),
    nl,
    read(X),
    (X == 'exit' ->
     loop('exit')
    ;
     nl,
     write('You added: '),
     write(X),
     assert(person(X)), % Add to the database
     nl,
     loop('normal')).
