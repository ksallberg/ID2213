


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

createBoard(0, Y, List) :-  nl.
createBoard(X, Y, List) :-  createLine(Y, List),
                            NewX is X - 1,
                            createBoard(NewX, Y, List).

%base case. The line is ready so print it
createLine(0, List) :-  print(List).
createLine(Y, List) :-  append(List, [~], Newlist),
                        NewY is Y - 1,
                        createLine(NewY, Newlist).

print([]) :-    nl.
print([Head|Tail]) :-   write(Head),
                        print(Tail).


play(Width, Height, Board) :- write('Give the X coordinate of the bomb: '),
        read(X),
        nl,
        write('Give the Y coordinate of the bomb: '),
        read(Y),
        boom(X, Y, Width, Height),
        play(Width, Height, Board).



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