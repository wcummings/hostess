-module(hostess).
-export([new/1, transaction/2]).

new(Name) ->
    hostess_server:new_table(Name).

transaction(Name, Func) ->
    gen_server:call(Name, {transaction, Func}).
