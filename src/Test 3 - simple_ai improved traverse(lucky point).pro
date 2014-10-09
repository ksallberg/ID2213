%% The idea of the database AI is to randomly choose positions to shoot at
%% until a hit is found, when a hit is found, it tries to shoot in surrounding
%% squares until the ship is sunk. Then it begins to shoot at random places.

%:- use_module(library(random)).

debug_board([[~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~],
             [~,~,~,~,~,~,~,~,~,~]]).
             
fleet(Fleet) :- 
        Ship1 = {
                   [[1,1], [2,1], [3,1],[4,1],[5,1]],    % Starting position
                   [],       % hitting points
                   [3,1]     % zhengyangs lucky point
                },
        Ship2 = {
                   [[4,2],[4,3],[4,4],[4,5],[4,6]],
                   [],
                   [4,4]
                },
        Fleet = [Ship1, Ship2].

test_ai :-
    debug_board(Board),
    fleet(Fleet),
    traverse(Fleet, [4,2], SinkList, ResultList),
    reverse(ResultList, RevList),
    write(RevList).


% get prediction points from start point and store in ResultList
traverse(Fleet, StartPoint, SinkList, ResultList) :- 
        traverse_single_point(Fleet, StartPoint, 0, [], SinkList, [StartPoint], ResultList).

% border point
traverse_single_point(Fleet, Point, Counter, AccSinkList, SinkList, AccResultList, ResultList) :- 
        Counter < 4,
        get_next_point(Point, Counter, NextPoint),
        [X,Y] = NextPoint,
        (X<0; X>9; Y<0; Y>9),
        NewCounter is Counter+1,
        traverse_single_point(Fleet, Point, NewCounter, AccSinkList, SinkList, AccResultList, ResultList).
% miss point
traverse_single_point(Fleet, Point, Counter, AccSinkList, SinkList, AccResultList, ResultList) :- 
        Counter < 4,
        get_next_point(Point, Counter, NextPoint),
        \+ member(NextPoint, AccResultList),
        test_drop_point(NextPoint, Fleet, 'm'),
        NewAccResultList = [NextPoint|AccResultList],
        NewCounter is Counter+1,
        traverse_single_point(Fleet, Point, NewCounter, AccSinkList, SinkList, NewAccResultList, ResultList).
% lucky point
traverse_single_point(Fleet, Point, Counter, AccSinkList, SinkList, AccResultList, ResultList) :- 
        Counter < 4,
        get_next_point(Point, Counter, NextPoint),
        [X,Y] = NextPoint,
        test_drop_point([X,Y], Fleet, 's'),
        NewAccResultList = [NextPoint|AccResultList],
        get_ship_coordinate([X,Y], Fleet, CoordinateList),
        % update sink list
        append(AccSinkList, CoordinateList, NewAccSinkList),
        NewCounter = 4,
        traverse_single_point(Fleet, Point, NewCounter, NewAccSinkList, SinkList, NewAccResultList, ResultList).        
% already tried point
traverse_single_point(Fleet, Point, Counter, AccSinkList, SinkList, AccResultList, ResultList) :- 
        Counter < 4,
        get_next_point(Point, Counter, NextPoint),
        member(NextPoint, AccResultList),
        NewCounter is Counter+1,
        traverse_single_point(Fleet, Point, NewCounter, AccSinkList, SinkList, AccResultList, ResultList).
% hit point
% hit point in SinkList
traverse_single_point(Fleet, Point, Counter, AccSinkList, SinkList, AccResultList, ResultList) :- 
        Counter < 4,
        get_next_point(Point, Counter, NextPoint),
        \+ member(NextPoint, AccResultList),
        test_drop_point(NextPoint, Fleet, 'h'),
        NewAccResultList = [NextPoint|AccResultList],
        % get NewSinkList from the next hit point and pass it when backtracking
        traverse_single_point(Fleet, NextPoint, 0, AccSinkList, NextSinkList, NewAccResultList, NextResultList),
        % get new sink list from recursion
        member(Point, NextSinkList),
        % point in new sink list does not try any other direction
        NewCounter = 4,
        traverse_single_point(Fleet, Point, NewCounter, NextSinkList, SinkList, NextResultList, ResultList).
% hit point not in SinkList
traverse_single_point(Fleet, Point, Counter, AccSinkList, SinkList, AccResultList, ResultList) :- 
        Counter < 4,
        get_next_point(Point, Counter, NextPoint),
        \+ member(NextPoint, AccResultList),
        test_drop_point(NextPoint, Fleet, 'h'),
        NewAccResultList = [NextPoint|AccResultList],
        % get NewSinkList from the next hit point and pass it when backtracking
        traverse_single_point(Fleet, NextPoint, 0, AccSinkList, NextSinkList, NewAccResultList, NextResultList),
        \+ member(Point, NextSinkList),
        % point not in new sink list continues to try other direction
        NewCounter is Counter+1,
        traverse_single_point(Fleet, Point, NewCounter, NextSinkList, SinkList, NextResultList, ResultList).
traverse_single_point(Fleet, Point, 4, AccSinkList, AccSinkList, AccResultList, AccResultList).
        

get_next_point(CenterPoint, 0, NextPoint) :-
        [X,Y] = CenterPoint,
        NewY is Y-1,
        NextPoint = [X,NewY].
get_next_point(CenterPoint, 1, NextPoint) :-
        [X,Y] = CenterPoint,
        NewX is X-1,
        NextPoint = [NewX,Y].
get_next_point(CenterPoint, 2, NextPoint) :-
        [X,Y] = CenterPoint,
        NewY is Y+1,
        NextPoint = [X,NewY].
get_next_point(CenterPoint, 3, NextPoint) :-
        [X,Y] = CenterPoint,
        NewX is X+1,
        NextPoint = [NewX,Y].
        

% test_drop_point([X,Y], Fleet, Result)
% check the shoot [X,Y] is 's' sink, or 'h' hit, or 'm' miss.
test_drop_point([X,Y], [H|T], 's') :-
        lucky_point([X,Y], H).
test_drop_point([X,Y], [H|T], 'h') :- 
        hit([X,Y], H).
test_drop_point([X,Y], [H|T], Result) :- 
        miss([X,Y], H),
        test_drop_point([X,Y], T, Result).
test_drop_point([X,Y], [], 'm').

lucky_point([X,Y], Ship) :-
        {CoordinateList,HitList,LuckyPoint} = Ship,
        [X,Y] == LuckyPoint.
hit([X,Y], Ship) :- 
        {CoordinateList,HitList,LuckyPoint} = Ship,
        [X,Y] \= LuckyPoint,
        member([X,Y], CoordinateList).
miss([X,Y], Ship) :- 
        {CoordinateList,HitList,LuckyPoint} = Ship,
        \+ member([X,Y], CoordinateList).

% get the coordinate list of the ship which contains [X,Y]
get_ship_coordinate([X,Y], [H|T], CoordinateList) :- 
        {CoordinateList, _, _} = H,
        member([X,Y], CoordinateList).
get_ship_coordinate([X,Y], [H|T], CoordinateList2) :-
        {CoordinateList1, _, _} = H,
        \+ member([X,Y], CoordinateList1),
        get_ship_coordinate([X,Y], T, CoordinateList2).
get_ship_coordinate([X,Y], [], []).



go_to_row(Y, [H|T], Yrow) :-
        NewY is Y-1,
        go_to_row(NewY, T, Yrow).
go_to_row(0, [H|_], H).

go_to_col(X, [H|T], Xcol) :-
        NewX is X-1,
        go_to_col(NewX, T, Xcol).
go_to_col(0, [H|_], H).


reverse(L, R) :- accRev(L, [], R).
accRev([H|T], Acc, R) :- accRev(T, [H|Acc], R).
accRev([], Acc, Acc).





