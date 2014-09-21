%% Create an initial matrix/ocean, with no ships
ocean(X) :- X = [[~,~,~,~,~,~,~,~,~,~],
                 [~,~,~,~,~,~,~,~,~,~],
                 [~,~,~,~,~,~,~,~,~,~],
                 [~,~,~,~,~,~,~,~,~,~],
                 [~,~,~,~,~,~,~,~,~,~],
                 [~,~,~,~,~,~,~,~,~,~],
                 [~,~,~,~,~,~,~,~,~,~],
                 [~,~,~,~,~,~,~,~,~,~],
                 [~,~,~,~,~,~,~,~,~,~],
                 [~,~,~,~,~,~,~,~,~,~]].

test_print(Size) :- new_ocean(Size, Board),
                    print_board(Board).

new_ocean(Size, Board) :- ocean_of_size(Size, Size, Board).

ocean_of_size(0, Size, [])    :- [].
ocean_of_size(X, Size, Board) :- NewX is X-1,
                                 ocean_of_size(NewX, Size, Next),
                                 ocean_line(Size, ThisLine),
                                 append([ThisLine], Next, Board).

ocean_line(0, [])       :- [].
ocean_line(X, FullLine) :- NewX is X-1,
                           ocean_line(NewX, Next),
                           append([~], Next, FullLine).

print_board([]) :- write('ok').
print_board([Line|Lines]) :- print_line(Line),
                             print_board(Lines).

print_line([]) :- nl.
print_line([Char|Chars]) :- write(Char),
                            print_line(Chars).


start :- write('Give the X coordinate: '), 
        read(X), 
        write(X),
        start.

