

test(X) :- X = [[1,2,3], [4,5,6], [7,8,9]], print2D(X).

%working. Creates half a christmas tree
createOcean(X, 0, List) :- nl.
createOcean(X, Y, List) :-  append(List, [~], Newlist),
                            print(Newlist),
                            NewY is Y - 1,
                            createOcean(X, NewY, Newlist).
%----------------- end of christmas tree -----------------


start :-    write('Give the Width of the board: '),
            read(Width),
            nl,
            write('Give the Height of the board: '),
            read(Height),
            nl,
            create(Width, Height, Board),
            play(Width, Height, Board).

create(Xd, Yd, Board) :-   createBoard(Xd, Yd, Board).

createBoard(0, Y, List) :-  write('ok'). %createLine(Y, List).
createBoard(X, Y, List) :-  NewX is X - 1,
                            createBoard(NewX, Y, Temp),
                            createLine(Y, Newlist),
                            append(Temp, [Newlist], List).
                            
%base case. The line is ready so print it
createLine(0, List) :-  print(List).
createLine(Y, List) :-  append(Newlist, [~], List),
                        NewY is Y - 1,
                        createLine(NewY, Newlist).

print2D([]) :-  nl.
print2D([Row|Rest]) :-  print(Row),
                        print2D(Rest).
print([]) :-    nl.
print([Head|Tail]) :-   write(Head),
                        print(Tail).


play(Width, Height, Board) :- write('Give the X coordinate of the bomb: '),
        read(X),
        nl,
        write('Give the Y coordinate of the bomb: '),
        read(Y),
        boom(X, Y, Width, Height, Board, NewBoard),
        print2D(NewBoard),
        play(Width, Height, NewBoard).


boom(X, Y, Width, 0, Board, L).
boom(X, Y, Width, Height, [H|T], L) :-  replace(X, Width, Y, Height, H, Newline), %height is the current line indicator
                                        %write(Newline),
                                        NHeight is Height - 1,
                                        boom(X, Y, Width, NHeight, T, Temp),
                                        append(Temp, [Newline], L).

%Drop the bomb into the board
replace(X, 0, Y, Height,  List, Newlist). %:- [].
replace(X, Width, Y, Height, [], Newlist).% :- [].

%the actual replace takes place
replace(X, X, Y, Y, [H|T], [o|Tt]) :- replace(X, X - 1, Y, Y, T, Tt).

%simple copy operation
replace(X, Width, Y, Height, [H|T], [H|Tt]) :-  NWidth is Width - 1,
                                                replace(X, NWidth, Y, Height, T, Tt).


%works but it has not memory of previous bombs dropped
boom(X, Y, Width, 0) :- nl.
boom(X, Y, Width, Height) :-    scanLine(X, Width, Y, Height), %height is the current line indicator
                                NHeight is Height - 1,
                                boom(X, Y, Width, NHeight).

scanLine(X, X, Y, Y) :- write('o'),
                        scanLine(X, X - 1, Y, Y).
scanLine(X, 0, Y, Height) :- nl.
scanLine(X, Width, Y, Height) :-    write('~'),
                                    NWidth is Width - 1,
                                    scanLine(X, NWidth, Y, Height).
%-------------------------------------------------------