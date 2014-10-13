ships3(Ships) :-
    Shipa = {
             [[0,0], [0,1], [0,2]],
             [],
             [0,1]
            },
    Shipb = {
             [[5,5], [6,5], [7,5]],
             [],
             [6,5]
            },
    %possible clash here
    Shipc = {
             [[7,8], [8,8], [9,8]],
             [],
             [8,8]
            },
    %possible clash here
    Shipd = {
             [[4,7], [4,8], [4,9]],
             [],
             [0,8]
            },
    Ships = [Shipa, Shipb, Shipc, Shipd].

ships4(Ships) :-
    %possible clash here
    Shipa = {
             [[4,8], [5,8], [6,8],[7,8]],
             [],
             [[5,8], [6,8]]
            },

    %possible clash here
    Shipb = {
             [[8,6], [8,7], [8,8],[8,9]],
             [],
             [[8,7], [8,8]]
            },
    Shipc = {
             [[5,1], [5,2], [5,3],[5,4]],
             [],
             [[5,2], [5,3]]
            },
    Shipd = {
             [[6,9], [7,9], [8,9],[9,9]],
             [],
             [[4,9], [5,9]]
            },
    Ships = [Shipa, Shipb, Shipc, Shipd].


create_fleet(Fleet) :-
    ships3(Fleet3),
    ships4(Fleet4),

    choose_NSized_Ships(1, 4, Fleet3, 0, [], NFleet),
    print2D(NFleet),nl,
    choose_NSized_Ships(2, 4, Fleet4, 1, NFleet, NNFleet),

    append(NFleet, NNFleet, Fleet),
    nl,write('Printing fleet:'), nl,
    print2D(Fleet),nl.


choose_NSized_Ships(0, FleetSize, Fleet, Flag, Buffer, NFleet) :-
    length(NFleet, Length),
    Length == 0,
    NFleet = [].

choose_NSized_Ships(N, FleetSize, Fleet, Flag, Buffer, NFleet) :-
    NN is N - 1,
    (Flag == 0 ->
        choose_NSized_Ships(NN, FleetSize, Fleet, Flag, Buffer, Temp),
        pick_random_ship(1, FleetSize, Fleet, Temp, Ship)
                ;
        choose_NSized_Ships(NN, FleetSize, Fleet, Flag, Buffer, Temp),
        append(Temp, Buffer, NBuffer),
        pick_random_ship(1, FleetSize, Fleet, NBuffer, Ship)
    ),
    {ShipCoords, _, _} = Ship,
    append(Temp, [Ship], NFleet).

%picks a unique random element from the list and stores it to Ship
pick_random_ship(1, N, Ships, TempList, Ship) :-
    UpperBound is N + 1,
    random(1, UpperBound, Rand),
    nth1(Rand, Ships, S),
    {ShipCoords, _, _} = S,
    write('Selected Ship: '), write(ShipCoords), nl,
    (not(collision(ShipCoords, TempList)) ->
        write('clash, attempting again'),nl,
        pick_random_ship(1, N, Ships, TempList, NewShip),
        append([], NewShip, Ship)
    ;
        append([], S, Ship)
    ).

collision(Ship, []).
collision(Ship, [H|T]) :- {ShipCoords, _, _} = H,
                          clash_free(Ship, ShipCoords),
                          collision(Ship, T).


%we are handling now lists with coordinates
clash_free([], FleetShip).
clash_free([H|T], FleetShip) :-
    not(member(H, FleetShip)),
    clash_free(T, FleetShip).


print2D([]) :-  nl.
print2D([Row|Rest]) :- print1D(Row),
                       print2D(Rest).

print1D({Ship, _, _}) :- write(Ship),nl.

