:- use_module(library(random)).

%% Stupid AI is totally random.
ai_choice(Board, [RandX, RandY]) :-
    random(0, 9, RandX),
    random(0, 9, RandY).
