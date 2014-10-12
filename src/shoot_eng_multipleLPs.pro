:- [ocean_engine].

%%********************* SHOOTING HANDLING FUNCTIONS *********************

% shoot([X,Y], Player, UpdatedPlayer)
% the overall shoot function
shoot([X,Y], {Board, Sunk, Fleet}, {NewBoard, NewSunkShips, NewFleet}) :-

              check_shoot([X,Y], Fleet, 's', NewFleet), 
			  write(': '), write('SHOOT_Fs: '),write(NewFleet),nl,
              get_ship_coordinate([X,Y], Fleet, CoordinateList),
              update_sink_ship(CoordinateList, 's', Board, NewBoard),
			  NewSunkShips = ['S'|Sunk],
			  write(': '), write('Fs_SUNK SHIPS: '),write(NewSunkShips),nl.
	
%% shoots a lucky point among many. It is an intermediate 's' state which is 'si',
%% and it is necessary as it keeps track of the shot lucky points
shoot([X,Y], {Board, Sunk, Fleet}, {NewBoard, Sunk, NewFleet}) :-

              check_shoot([X,Y], Fleet, 'si', NewFleet), 
			  write(': '),write('SHOOT_Fsi: '),write(NewFleet),nl,
			  update_point([X,Y], 'h', Board, NewBoard),
			  write(': '), write('Fsi_SUNK SHIPS: '),write(Sunk),nl.

shoot([X,Y], {Board, Sunk, Fleet}, {NewBoard, Sunk, NewFleet}) :-

              check_shoot([X,Y], Fleet, 'h', NewFleet), 
			  write(': '),write('SHOOT_Fh: '),write(NewFleet),nl,
              update_point([X,Y], 'h', Board, NewBoard).

shoot([X,Y], {Board, Sunk, Fleet}, {NewBoard, Sunk, NewFleet}) :-

              check_shoot([X,Y], Fleet, 'm', NewFleet),
			  write(': '),write('SHOOT_Fm: '),write(NewFleet),nl,
              update_point([X,Y], 'm', Board, NewBoard).


			  
% check_shoot([X,Y], Fleet, Result, NewFleet)
% check the shoot [X,Y] is 's' sink, or 'h' hit, or 'm' miss.
% If shoot is 's' or 'h', update the Ship and Fleet.

check_shoot([X,Y], [H|T], 's', NewFleet) :-
        check_luckyPoint([X,Y], H, 's', NewShip),
        NewFleet = [NewShip|T].

check_shoot([X,Y], [H|T], 'si', NewFleet) :-
        check_luckyPoint([X,Y], H, 'si', NewShip),
        NewFleet = [NewShip|T].
		
check_shoot([X,Y], [H|T], 'h', NewFleet) :-
        check_hit([X,Y], H, 'h', NewShip),
        NewFleet = [NewShip|T].

check_shoot([X,Y], [H|T], Result, [H|NewFleet]) :-
        check_miss([X,Y], H),
        check_shoot([X,Y], T, Result, NewFleet).

check_shoot([X,Y], [], 'm', []).

% check_luckyPoint([X,Y], Ship, Result, NewShip)
%% Check if a lucky point is shot. If so, increase the shot LPs counter
%% and check if there are more LPs to be shot

check_luckyPoint([X,Y], Ship, 's', NewShip) :-
        {CoordinateList,HitList,LuckyPoint} = Ship,
        %[X,Y] == LuckyPoint,
		
		member([X,Y], LuckyPoint),

		%increase the shot lucky points counter (last element of the lucky list)
		shoot_luckyPoint(LuckyPoint, NewLucky),
		
		%check if all the lucky points have been shot
		exhausted_luckyPoints(NewLucky),
		
        NewHitList = CoordinateList,
        NewShip = {CoordinateList,NewHitList,NewLucky}.
		
%% checks if a LP is shot, and if so, records this action for future use
check_luckyPoint([X,Y], Ship, 'si', NewShip) :-
        {CoordinateList,HitList,Lucky} = Ship,
		
		member([X,Y], Lucky),
		write(': '),write('member of lucky point si '),nl,
		%increase the shot lucky points counter (last element of the lucky list)
		shoot_luckyPoint(Lucky, NewLucky),
		
        append(HitList,[X,Y], NewHitList),
        NewShip = {CoordinateList,NewHitList,NewLucky}.
		
		
%% increases the shot lucky points pointer
shoot_luckyPoint(Lucky, NewLucky) :-
	
	length(Lucky, Length),
	
	%% get the shot counter
	nth1(Length, Lucky, Last),
	NewCounter is Last + 1,
	
	%save the first Length - 1 elements from the list
	Save is Length - 1,
	take(Save, Lucky, [], Temp),
	
	%% put everything together
	append(Temp, [NewCounter], NewLucky),
	write(': '),write('SHOOT LUCKY POINT'),nl,
	write(NewLucky),nl.
	
	
exhausted_luckyPoints(Lucky) :-
	
	%if the last element of the list (number of sunk lucky points)
	%equals the length of the Lucky - 1, then all lucky points are sunk
	write(': '),write('CHECKING EXHAUSTED LUCKY POINTS'),nl,
	length(Lucky, Length),
	ActualLength is Length - 1,
	nth1(Length, Lucky, Last),

	Last == ActualLength,
	write(': '),write('EXHAUSTED LUCKY POINTS. SHIP SUNK'),nl.
		
% check_hit([X,Y], Ship, Result, NewShip)
% if [X,Y] is hit, return true and update ship state, Result = 'h'
check_hit([X,Y], Ship, 'h', NewShip) :-
        {CoordinateList,HitList,LuckyPoint} = Ship, write(':'),write('HIT  '),write(Ship),nl,
        %%[X,Y] \= LuckyPoint,
		
		\+ member([X,Y], LuckyPoint),
		
        member([X,Y], CoordinateList),write('ship was hit at '),write([X,Y]),nl,
        append(HitList,[X,Y], NewHitList),
        NewShip = {CoordinateList,NewHitList,LuckyPoint}.

% check_hit([X,Y], Ship)
% if [X,Y] is missing, return true
check_miss([X,Y], Ship) :-
        {CoordinateList,HitList,LuckyPoint} = Ship,
        \+ member([X,Y], CoordinateList).
		

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
		
		
% update the point [X,Y] on the board with the Result character('s', 'h', 'm')
update_point([X,Y], Result, Board, NewBoard) :-
        split(Y, Board, BeforeLines, WantedLine, AfterLines),
        split(X, WantedLine, BeforeCells, WantedCell, AfterCells),
        merge(BeforeCells, Result, AfterCells, NewLine),
        merge(BeforeLines, NewLine, AfterLines, NewBoard).
		
		
%%********************* END OF SHOOTING HANDLING FUNCTIONS ******************	
