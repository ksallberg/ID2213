:- [simple_ai, shipyard, shooting_engine].

% The game state is represented as:
% {Player,  %Player
%  Computer %Player
% }

% A Player is represented as:
% {
%	GameBoard,
%	SunkCounter,
%   [Ships]
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
                   [[3,2],[4,2],[5,2]],    % Ship positions
                   [],                       % hit points? FIXME whats this?
                   [4,2]           % zhengyangs lucky point
                },
        Ship2 = {  [[4,4],[5,4],[6,4]],
                   [],
                   [5,4]
                },
        Fleet = [Ship1, Ship2].

new_ocean(Size, Board) :- ocean_of_size(Size, Size, Board).

ocean_of_size(0, _Size, [])   :- [].
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
        create_fleet(Fleet),
		%fleet(Fleet),
        Player = {InitialBoard, 0, Fleet}.

%% Starting point
start :-
        new_ocean(10, InitialBoard),
        create_state(InitialBoard, HumanSlave),
        create_state(InitialBoard, ComputerLord),
        game_config({HumanSlave, ComputerLord}).


%test the validity of input
valid_input(q).
valid_input([X,Y]) :- number(X), number(Y), X >= 0 , Y >= 0.

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
	game_loop(Mode, {Human, AI}, 'YES').


%% ********************** THE MIGHTY CORE ENGINE ************************

game_loop("q")      :- write('Goodbye ship sinker!').
game_loop(Mode, {Human, AI}, 'YES') :-
    {AIGameBoard,    _AISunk,    AIFleet}    = AI,
    {HumanGameBoard, HumanSunk, HumanFleet} = Human,

    %% Before the human player gets its turn, let the AI play
    ai_choice(AIGameBoard, AIInput),

    shoot(AIInput, AI, {AINewBoard, AINewSunk, AINewFleet}),
	game_ended(AINewSunk, AIFleet, AiWins),
	ai_response(AiWins, AiContinue),

    println('Hello, I am the mighty AI, this is my board so far:'),
    print_board(AINewBoard), nl,

    %% AI has played. Now its the humans turn:
    println('This is your board, ship sinker: '),
	print_board(HumanGameBoard), nl,

	(Mode == a ->
		%% automatic mode, the computer keeps shooting and the slave (human) watches
		%sleep(1),
		game_loop(Mode, {{HumanGameBoard, HumanSunk, HumanFleet},
                   {AINewBoard, AINewSunk, AINewFleet}}, AiContinue)
	;

		println('Shoot at [X,Y]:'),

		read(Input),
		check_input(Input, ValidInput),
		(q == ValidInput ->
			game_loop("q")
		;
			nl,
			[X,Y] = ValidInput,
			shoot([X,Y],
				  Human,
				  {HumanNewBoard, HumanNewSunk, HumanNewFleet}),

			game_ended(HumanNewSunk, HumanFleet, HumanWins),
			human_response(HumanWins, HumanContinue),

			decide_to_continue(AiContinue, HumanContinue, FinalContinue),

			game_loop(Mode, {{HumanNewBoard, HumanNewSunk, HumanNewFleet},
					   {AINewBoard, AINewSunk, AINewFleet}}, FinalContinue)
		)
	).

%% The last parameter is NO, that is the game has to end
game_loop(_Mode, {Human, AI}, 'NO') :-

	{AIBoard, AISunk, _} = AI,
    {HumanBoard, HumanSunk, _} = Human,

	println('_______Game ended_______'),
	print_board(AIBoard), nl,
	print_board(HumanBoard), nl,

	%length(AISunk, AIScore),
	%length(HumanSunk, HumanScore),

	(AISunk > HumanSunk ->
		println('You lose ship sinker')
	;
		println('You win ship sinker')
	),

	game_loop("q").

%% If someone wins (YES), then the game must not continue (NO)
ai_response('YES', 'NO').
ai_response('NO', 'YES').
human_response('YES', 'NO').
human_response('NO', 'YES').

decide_to_continue('NO', _, 'NO').
decide_to_continue(_, 'NO', 'NO').
decide_to_continue('YES', 'YES', 'YES').


game_ended(Sunk, Fleet, Response) :-
	length(Fleet, CountFleet),

	Sunk == CountFleet,
	Response = 'YES'.

game_ended(Sunk, Fleet, Response) :-
	length(Fleet, CountFleet),
	Sunk \= CountFleet,
	Response = 'NO'.


println(String) :- write(String),nl.
