

ships3(Ships) :-  Shipa = {
                        [[0,0], [0,1], [0,2]],    
                        [],       
                        [0,1],
                        0 %indicates whether this ship is already on the board
                     },
                Shipb = {
                        [[5,5], [6,5], [7,5]],    
                        [],     
                        [6,5],
                        0
                     },
                %possible clash here
                Shipc = {
                        [[7,8], [8,8], [9,8]],    
                        [],     
                        [8,8],
                        0
                     },
                %possible clash here
                Shipd = {
                        [[4,7], [4,8], [4,9]],    
                        [],     
                        [0,8],
                        0
                     },
                Ships = [Shipa, Shipb, Shipc, Shipd].

ships4(Ships) :-
        %possible clash here
        Shipa = {
                   [[4,8], [5,8], [6,8],[7,8]],    
                   [],       
                   [[5,8], [6,8]],
                   0
                },

        %possible clash here
        Shipb = {
                   [[8,6], [8,7], [8,8],[8,9]],    
                   [],     
                   [[8,7], [8,8]],
                   0
                },
        Shipc = {
                   [[5,1], [5,2], [5,3],[5,4]],    
                   [],     
                   [[5,2], [5,3]],
                   0
                },
        Ships = [Shipa, Shipb, Shipc].


createFleet(Fleet) :- 
                        ships3(Fleet3),
                        ships4(Fleet4),

                        chooseNSizedShips(3, 4, Fleet3, NewFleet),
                        chooseNSizedShips(2, 3, Fleet4, NewFleet),

                        Fleet = NewFleet,
                        write(NewFleet),
                        print2D(NewFleet),nl.


chooseNSizedShips(0, FleetSize, Fleet, NFleet).
chooseNSizedShips(N, FleetSize, Fleet, NFleet) :- 
                                
                                pickRandomShip(1, FleetSize, Fleet, Ship),

                                {ShipCoords, _, _, _} = Ship,
                                write('Selected Ship: '), write(ShipCoords), nl,

                                %if it evaluates to false, there is clash
                                doesClash(ShipCoords, NFleet),

                                append(NFleet, [Ship], NNNF),

                                %SelectedFlag == 0,
                                NewN is N - 1,
                                NFleet = NNNF,
                                chooseNSizedShips(NewN, FleetSize, Fleet, NNNF).


%when there is a ship selection clash solve it
chooseNSizedShips(N, FleetSize, Fleet, [H|T]) :-
                                {ShipCoords, _, _, _} = H,
                                write('there was a clash at ship '),
                                write(ShipCoords),nl,
                                write('attempting again:'),nl,
                                chooseNSizedShips(N, FleetSize, Fleet, [H|T]).


doesClash(Ship, []). % :- write('no clash yet'),nl.                     
doesClash(Ship, [H|T]) :-   {ShipCoords, Hitlist, Lucky, SelectedFlag} = H,
                            noClash(Ship, ShipCoords),
                            doesClash(Ship, T).


%we are handling now lists with coordinates
noClash([], FleetShip).
noClash([H|T], FleetShip) :-    not(member(H, FleetShip)),
                                noClash(T, FleetShip).   



%picks a random element from the list and binds it to Ship
pickRandomShip(1, N, Ships, Ship) :-    random_between(1, N, Rand),
                                        nth1(Rand, Ships, Ship).


print2D([]) :-  nl.
print2D([Row|Rest]) :-  print(Row),
                        print2D(Rest).
print([]) :-    nl.
print([Head|Tail]) :-   write(Head),
                        print(Tail).