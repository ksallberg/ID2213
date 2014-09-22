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

%% Starting position
play :- new_ocean(10, InitialBoard),
        game_loop(InitialBoard).


%% take(3, [a,b,c,d], [], Y). :: Y = [a,b,c] ?
take(0,    In,    Out, Out).
take(Size, [H|T], Acc, NewOut) :- NewSize is Size -1,
                                  append(Acc,[H],NewAcc),
                                  take(NewSize, T, NewAcc, NewOut).

%% drop(2, [a,b,c,d], Y). :: Y = [c,d] ?
drop(0,    Out,   Out).
drop(Size, [H|T], NewOut) :- NewSize is Size - 1,
                             drop(NewSize, T, NewOut).

split(Size, Ls, Before, Wanted, FinalAfter) :-
    take(Size, Ls, [], Before),
    drop(Size, Ls, After),
    take(1, After, [], [Wanted|_]),
    drop(1, After, FinalAfter).

merge(Before, Wanted, After, Result) :-
    append(Before, [Wanted], X),
    append(X, After, Result).

shoot([X,Y], Board, NewBoard) :-
    split(Y, Board, BeforeLines, WantedLine, AfterLines),
    write('wanted line:'),
    nl,
    write(WantedLine),
    nl,
    split(X, WantedLine, BeforeCells, WantedCell, AfterCells),
    write('wanted cell:'),
    nl,
    write(WantedCell),
    nl,
    merge(BeforeCells, m, AfterCells, NewLine),
    merge(BeforeLines, NewLine, AfterLines, NewBoard).

%test the validity of input
valid_input(stop).
valid_input([X,Y]) :- number(X), number(Y).

%loop until valid input is got
check_input(Input, Input) :- valid_input(Input).
check_input(Input, Valid) :- 
        \+ valid_input(Input),
        write('Illegal input, please shoot at [X,Y]'),
        nl,
        read(NewInput),
        check_input(NewInput, Valid).


game_loop("stop")    :- write('Goodbye ship sinker!').
game_loop(GameBoard) :- write('This is your board: '),
                        nl,
                        print_board(GameBoard),
                        nl,
                        write('Shoot at [X,Y]:'),
                        nl,
                        read(Input),
                        check_input(Input, ValidInput),
                        (stop == ValidInput ->
                            game_loop("stop")
                        ;
                            nl,
                            [X,Y] = ValidInput,
                            shoot([X,Y], GameBoard, NewBoard),
                            nl,
                            game_loop(NewBoard)
                        ).
