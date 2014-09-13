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
