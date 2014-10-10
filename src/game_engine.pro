:- [simple_ai, shipyard].

% The game state is represented as:
% {Player,  %Player
%  Computer %Player
% }

% A Player is represented as:
% {GameBoard,
%  [SunkenShips],
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
                   [[3,2], [4,2], [5,2]],    % Ship positions
                   [],                       % hit points? FIXME whats this?
                   [5,2]                     % zhengyangs lucky point
                },
        Ship2 = {  [[4,4], [5,4], [6,4]],
                   [],
                   [6,4]
                },
        Fleet = [Ship1, Ship2].

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

print_board([]) :- nl.
print_board([Line|Lines]) :- print_line(Line),
                             print_board(Lines).

print_line([]) :- nl.
print_line([Char|Chars]) :- write(Char),
                            print_line(Chars).

create_state(InitialBoard, Player) :-
        %createFleet(Fleet),
		fleet(Fleet),
        Player = {InitialBoard, [], Fleet}.

%% Starting point
start :-
        new_ocean(10, InitialBoard),
        create_state(InitialBoard, HumanSlave),
        create_state(InitialBoard, ComputerLord),
        game_config({HumanSlave, ComputerLord}).

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
shoot([X,Y], {Board, AISunken, Fleet}, {NewBoard, NewSunkenShips, NewFleet}) :-
              check_shoot([X,Y], Fleet, 's', NewFleet),
              get_ship_coordinate([X,Y], Fleet, CoordinateList),
              update_sink_ship(CoordinateList, 's', Board, NewBoard),
			  NewSunkenShips = [S|AISunken].

shoot([X,Y], {Board, [], Fleet}, {NewBoard, [], NewFleet}) :-
              check_shoot([X,Y], Fleet, 'h', NewFleet),
              update_point([X,Y], 'h', Board, NewBoard).

shoot([X,Y], {Board, [], Fleet}, {NewBoard, [], NewFleet}) :-
              check_shoot([X,Y], Fleet, 'm', NewFleet),
              update_point([X,Y], 'm', Board, NewBoard).


%test the validity of input
valid_input(stop).
valid_input([X,Y]) :- number(X), number(Y), X > 0 , Y > 0.

%loop until valid input is given
check_input(s, [0,0]).
check_input(Input, Input) :- valid_input(Input).
check_input(Input, Valid) :-
        \+ valid_input(Input),
        write('Illegal input, please shoot at [X,Y], X and Y are positive numbers.'),
        nl,
        read(NewInput),
        check_input(NewInput, Valid).

game_config({Human, AI}) :-
	println('Hello human slave, do you want automatic (a), or manual (m) play mode?'),
	read(Mode),
	game_loop(Mode, {Human, AI}).

game_loop("stop")      :- write('Goodbye ship sinker!').
game_loop(Mode, {Human, AI}) :-
    {AIGameBoard,    AISunken,    AIFleet}    = AI,
    {HumanGameBoard, HumanSunken, HumanFleet} = Human,

	%% Before the human player gets its turn, let the AI play
    ai_choice(AIGameBoard, AIInput),print('computer strikes at'), println(AIInput),
	
	%% check if the game must end
	\+ game_ended(AISunken, AIFleet),
	\+ game_ended(HumanSunken, HumanFleet),

    
    shoot(AIInput, AI, {AINewBoard, AINewSunken, AINewFleet}),

    println('Hello, I am the mighty AI, this is my board so far:'),
    print_board(AINewBoard), nl,

    %% AI has played. Now its the humans turn:
    println('This is your board, ship sinker: '),
	print_board(HumanGameBoard), nl,

	(Mode == a ->
		%% automatic mode, the computer keeps shooting and the slave (human) watches
		%sleep(1),
		game_loop(Mode, {{HumanGameBoard, HumanSunken, HumanFleet},
                   {AINewBoard, AINewSunken, AINewFleet}})
	;

		println('Shoot at [X,Y]:'),

		read(Input),
		check_input(Input, ValidInput),
		(stop == ValidInput ->
			game_loop("stop")
		;
			nl,
			[X,Y] = ValidInput,
			shoot([X,Y],
				  Human,
				  {HumanNewBoard, HumanNewSunken, HumanNewFleet}),

			nl,
			game_loop(Mode, {{HumanNewBoard, HumanNewSunken, HumanNewFleet},
					   {AINewBoard, AINewSunken, AINewFleet}})
		)
	).

game_loop(Mode, {Human, AI}) :-

	{AIBoard, AISunken, _} = AI,
    {HumanBoard, HumanSunken, _} = Human,

	println('_______Game ended_______'),
	print_board(AIBoard), nl,
	print_board(HumanBoard), nl,

	length(AISunken, AIScore),
	length(HumanSunken, HumanScore),

	(AIScore > HumanScore ->
		println('You lose ship sinker')
	;
		println('You win ship sinker')
	),

	game_loop("stop").

game_ended(Sunken, Fleet) :-
	length(Sunken, CountSunk),
	length(Fleet, CountFleet),

	%%print('length of the fleet '),println(CountFleet),
	%%print('length of the sunk '),println(CountSunk),

	CountSunk == CountFleet.

print(String) :- write(String).
println(String) :- write(String),nl.
