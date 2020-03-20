%hasuaufgabe program
-module(hausaufgabe).
-import(io,[fwrite/1]).
-export([reverse/1]).
-export([concat/2]).
-export([find/2]).
-export([delete/2]).
-export([flatten/1]).
-export([squared/1]).
-export([filter/2]).
-export([maxi/1]).
-export([mini/1]).


concat([], _a) -> [_a];
concat(L1, []) -> L1;
concat(L1, [H]) -> concat(L1, H);
concat(L1, [H | T]) -> concat(concat(L1, H), T);
concat([H | T], _a) -> [H | concat(T, _a)].


reverse([]) -> [];
reverse([_a]) -> [_a];	
reverse([H|T]) -> [H2 | T2] = reverse(T), [ H2 | concat(T2, H)].


find(_n, []) -> not_found;
find(_n, [_n | _ ] ) -> {found, 1};
find(_n, [_ | T]) -> Result = find(_n, T),
	if
        Result =:= not_found ->
            not_found;
        true -> % works as an 'else' branch
           {found, Index} = Result, {found, Index + 1}
    end.

delete(_n, []) -> [];
delete(_n, [_n | T]) -> T;
delete(_n, [H | T]) -> [H | delete(_n, T)].


flatten([])->[];
flatten([[H|T]]) -> [H|T];
flatten([ L1, L2 | T] )-> flatten([concat(L1, L2) | T]).

squared(L) -> [E*E || E <- L].

filter(_, []) -> [];
filter(P, [H|T]) -> Result = P(H),
	if
        Result ->
            [H | filter(P, T)];
        true -> % works as an 'else' branch
            filter(P, T)
    end.

maxi([]) -> null;
maxi([H]) -> H;
maxi([H|T]) -> MaxiT = maxi(T),
	if
		H > MaxiT -> H;
		true -> MaxiT
	end.
	
mini([]) -> null;
mini([H]) -> H;
mini([H|T]) -> MiniT = mini(T),
	if
		H < MiniT -> H;
		true -> MiniT
	end.