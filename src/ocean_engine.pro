%%****************** OCEAN HANDLING FUNCTIONS ***************************

%% take(3, [a,b,c,d], [], Y). :: Y = [a,b,c] ?
take(0,    _In,   Out, Out).
take(Size, [H|T], Acc, NewOut) :- NewSize is Size -1,
                                  append(Acc, [H], NewAcc),
                                  take(NewSize, T, NewAcc, NewOut).

%% drop(2, [a,b,c,d], Y). :: Y = [c,d] ?
drop(0,    Out,   Out).
drop(Size, [_H|T], NewOut) :- NewSize is Size - 1,
                              drop(NewSize, T, NewOut).

split(Size, Ls, Before, Wanted, FinalAfter) :-
    take(Size, Ls, [], Before),
    drop(Size, Ls, After),
    take(1, After, [], [Wanted|_]),
    drop(1, After, FinalAfter).

merge(Before, Wanted, After, Result) :-
    append(Before, [Wanted], X),
    append(X, After, Result).

%%****************** END OF OCEAN HANDLING FUNCTIONS ********************
