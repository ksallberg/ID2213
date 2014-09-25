
% The game state is represented as:
% {Player,  %Player
%  Computer %Player
% }

% A Player is represented as:
% {GameBoard,
%  [Miss],
%  [Ships]
% }

% A ship is represented as:
% { [[X,Y],...]CoordinateList, <- coordinates of the ship
%   [Hitting point],
%   zhengyangs lucky point
% }

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

fleet(Fleet) :- 
        Ship1 = {
                   [[0,0], [0,1], [0,2]],    % Starting position
                   [],       % hitting points
                   [0,1]     % zhengyangs lucky point
                },
        Fleet = [Ship1].



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

create_state(InitialBoard, Player) :- 
        fleet(Fleet),
        Player = {InitialBoard, [], Fleet}.



%% Starting position
start :- 
        new_ocean(10, InitialBoard),
        create_state(InitialBoard, HumanSlave),
        create_state(InitialBoard, ComputerLord),
        game_loop({HumanSlave, ComputerLord}).



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


% check_shoot([X,Y], Fleet, Result, NewFleet)
% check the shoot [X,Y] is 's' sink, or 'h' hit, or 'm' miss.
% If shoot is 's' or 'h', update the Ship and Fleet. 
check_shoot([X,Y], [H|T], 's', NewFleet) :-
        check_luckyPoint([X,Y], H, 's', NewShip),
        NewFleet = [NewShip|T].
check_shoot([X,Y], [H|T], 'h', NewFleet) :- 
        check_hit([X,Y], H, 'h', NewShip),
        NewFleet = [NewShip|T].
check_shoot([X,Y], [H|T], Result, [H|NewFleet]) :- 
        check_miss([X,Y], H),
        check_shoot([X,Y], T, Result, NewFleet).
check_shoot([X,Y], [], 'm', []).

% check_luckyPoint([X,Y], Ship, Result, NewShip)
% if [X,Y] is lucky point, return true and update ship state, Result = 's'
check_luckyPoint([X,Y], Ship, 's', NewShip) :-
        {CoordinateList,HitList,LuckyPoint} = Ship,
        [X,Y] == LuckyPoint,
        NewHitList = CoordinateList,
        NewShip = {CoordinateList,NewHitList,LuckyPoint}.        

% check_hit([X,Y], Ship, Result, NewShip)
% if [X,Y] is hit, return true and update ship state, Result = 'h'
check_hit([X,Y], Ship, 'h', NewShip) :- 
        {CoordinateList,HitList,LuckyPoint} = Ship,
        [X,Y] \= LuckyPoint,
        member([X,Y], CoordinateList),
        append(HitList,[X,Y], NewHitList),
        NewShip = {CoordinateList,NewHitList,LuckyPoint}.

% check_hit([X,Y], Ship)
% if [X,Y] is missing, return true
check_miss([X,Y], Ship) :- 
        {CoordinateList,HitList,LuckyPoint} = Ship,
        \+ member([X,Y], CoordinateList).
        

% update the point [X,Y] on the board with the Result character('s', 'h', 'm')
update_point([X,Y], Result, Board, NewBoard) :-
        split(Y, Board, BeforeLines, WantedLine, AfterLines),
        split(X, WantedLine, BeforeCells, WantedCell, AfterCells),
        merge(BeforeCells, Result, AfterCells, NewLine),
        merge(BeforeLines, NewLine, AfterLines, NewBoard).


% if the ship sinks, update all the points in the ship coordinate list to 's'
update_sink_ship([H|T], Result, BoardIn, BoardOut) :-
        [X,Y] = H,
        update_point([X,Y], Result, Board2, BoardOut),
        update_sink_ship(T, Result, BoardIn, Board2).
update_sink_ship([], Result, Board, Board).

% get the coordinate list of the ship which contains [X,Y]
get_ship_coordinate([X,Y], [H|T], CoordinateList) :- 
        {CoordinateList, _, _} = H,
        member([X,Y], CoordinateList).
get_ship_coordinate([X,Y], [H|T], CoordinateList2) :-
        {CoordinateList1, _, _} = H,
        \+ member([X,Y], CoordinateList1),
        get_ship_coordinate([X,Y], T, CoordinateList2).
get_ship_coordinate([X,Y], [], []).
        
% shoot([X,Y], Player, UpdatedPlayer)
% the overall shoot function
shoot([X,Y], {Board, [], Fleet}, {NewBoard, [], NewFleet}) :-
              check_shoot([X,Y], Fleet, 's', NewFleet),
              get_ship_coordinate([X,Y], Fleet, CoordinateList),
              update_sink_ship(CoordinateList, 's', Board, NewBoard).
shoot([X,Y], {Board, [], Fleet}, {NewBoard, [], NewFleet}) :-
              check_shoot([X,Y], Fleet, 'h', NewFleet),
              update_point([X,Y], 'h', Board, NewBoard).
shoot([X,Y], {Board, [], Fleet}, {NewBoard, [], NewFleet}) :-
              check_shoot([X,Y], Fleet, 'm', NewFleet),
              update_point([X,Y], 'm', Board, NewBoard).

             
             
%test the validity of input
valid_input(stop).
valid_input([X,Y]) :- number(X), number(Y).

%loop until valid input is gotten
check_input(Input, Input) :- valid_input(Input).
check_input(Input, Valid) :-
        \+ valid_input(Input),
        write('Illegal input, please shoot at [X,Y], X and Y are numbers.'),
        nl,
        read(NewInput),
        check_input(NewInput, Valid).


game_loop("stop")    :- write('Goodbye ship sinker!').
game_loop({Human, {GameBoard, Misses, Fleet}}) :-
                        write('This is your board: '),
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
                            shoot([X,Y], {GameBoard, Misses, Fleet}, {NewBoard, Misses, NewFleet}),
                            nl,
                            game_loop({Human, {NewBoard, Misses, NewFleet}})
                        ).
