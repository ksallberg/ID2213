:- [simple_ai, shipyard, shooting_engine].

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
                   [[4,2], [5,2]],    % Ship positions
                   [],                       % hit points? FIXME whats this?
                   [5,2]                     % zhengyangs lucky point
                },
        Ship2 = {  [[5,4], [6,4]],
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
        %create_fleet(Fleet),
		fleet(Fleet),
        Player = {InitialBoard, [], Fleet}.

%% Starting point
start :-
        new_ocean(10, InitialBoard),
        create_state(InitialBoard, HumanSlave),
        create_state(InitialBoard, ComputerLord),
        game_config({HumanSlave, ComputerLord}).


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
	game_loop(Mode, {Human, AI}, YES).

	
%% ********************** THE MIGHTY CORE ENGINE ************************

game_loop("stop")      :- write('Goodbye ship sinker!').
game_loop(Mode, {Human, AI}, YES) :-
    {AIGameBoard,    AISunken,    AIFleet}    = AI,
    {HumanGameBoard, HumanSunken, HumanFleet} = Human,

	%% check if the game must end
	game_ended(AISunken, AIFleet, AiWins),
	game_ended(HumanSunken, HumanFleet, HumanWins),
	
	flat_response(AiWins, HumanWins, Continue),

    %% Before the human player gets its turn, let the AI play
    ai_choice(AIGameBoard, AIInput),%print('computer strikes at'), println(AIInput),
	
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
                   {AINewBoard, AINewSunken, AINewFleet}}, Continue)
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
					   {AINewBoard, AINewSunken, AINewFleet}}, Continue)
		)
	).

%% The last parameter is NO, that is the game has to end
game_loop(Mode, {Human, AI}, NO) :-

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

%% If someone wins (YES), then the game must not continue (NO)
flat_response(YES, _, NO). % :- Response = NO.
flat_response(_, YES, NO). % :- Response = NO.
flat_response(NO, NO, YES). % :- Response = YES.

game_ended(Sunken, Fleet, Response) :-
	length(Sunken, CountSunk),
	length(Fleet, CountFleet),

	print('length of the fleet '),println(CountFleet),
	print('length of the sunk '),println(CountSunk),

	CountSunk == CountFleet,
	Response = YES.
	
game_ended(Sunken, Fleet, Response) :-
	Response = NO.
	

print(String) :- write(String).
println(String) :- write(String),nl.
