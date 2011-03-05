-module(tut).
-export([to_hex/1,md5string/1,test/0]).
to_hex([]) ->
    [];
to_hex(Bin) when is_binary(Bin) ->
    to_hex(binary_to_list(Bin));
to_hex([H|T]) ->
    [to_digit(H div 16), to_digit(H rem 16) | to_hex(T)].

to_digit(N) when N < 10 -> $0 + N;
to_digit(N)             -> $a + N-10.



md5string(Term) ->
	to_hex(erlang:md5(term_to_binary(Term))).

md5_hex(S) ->
Md5_bin =  erlang:md5(S),
Md5_list = binary_to_list(Md5_bin),
lists:flatten(list_to_hex(Md5_list)).

list_to_hex(L) ->
lists:map(fun(X) -> int_to_hex(X) end, L).

int_to_hex(N) when N < 256 ->
[hex(N div 16), hex(N rem 16)].

hex(N) when N < 10 ->
$0+N;
hex(N) when N >= 10, N < 16 ->
$a + (N-10).
	
test() ->
	Term = [false,2,<<132,177,33,86,22,138,138,208,203,193,154,7,213,99,156,213>>,{[{<<110,97,109,101>>,<<69,109,109,97>>},{<<97,103,101>>,3}]},[]],
	Bin = binary_to_list(term_to_binary(Term)),
	io:format(md5string(Term)).