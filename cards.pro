color(clubs).
color(diamonds).
color(hearts).
color(spades).

card(ace,   color(clubs)).
card(king,  color(clubs)).
card(queen, color(clubs)).
card(jack,  color(clubs)).
card('10',  color(clubs)).
card('9',   color(clubs)).
card('8',   color(clubs)).
card('7',   color(clubs)).
card('6',   color(clubs)).
card('5',   color(clubs)).
card('4',   color(clubs)).
card('3',   color(clubs)).
card('2',   color(clubs)).

card(ace,   color(diamonds)).
card(king,  color(diamonds)).
card(queen, color(diamonds)).
card(jack,  color(diamonds)).
card('10',  color(diamonds)).
card('9',   color(diamonds)).
card('8',   color(diamonds)).
card('7',   color(diamonds)).
card('6',   color(diamonds)).
card('5',   color(diamonds)).
card('4',   color(diamonds)).
card('3',   color(diamonds)).
card('2',   color(diamonds)).

card(ace,   color(hearts)).
card(king,  color(hearts)).
card(queen, color(hearts)).
card(jack,  color(hearts)).
card('10',  color(hearts)).
card('9',   color(hearts)).
card('8',   color(hearts)).
card('7',   color(hearts)).
card('6',   color(hearts)).
card('5',   color(hearts)).
card('4',   color(hearts)).
card('3',   color(hearts)).
card('2',   color(hearts)).

card(ace,   color(spades)).
card(king,  color(spades)).
card(queen, color(spades)).
card(jack,  color(spades)).
card('10',  color(spades)).
card('9',   color(spades)).
card('8',   color(spades)).
card('7',   color(spades)).
card('6',   color(spades)).
card('5',   color(spades)).
card('4',   color(spades)).
card('3',   color(spades)).
card('2',   color(spades)).

%% Return all of the cards in the deck
deck(List) :- findall(card(Value, color(Color)),
                      card(Value, color(Color)),
                      List).
