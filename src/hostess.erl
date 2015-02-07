-module(hostess).
-export([new/1, transaction/2, delete/1]).

new(Name) ->
    hostess_server:new_table(Name).

transaction(Name, Func) ->
    gen_server:call(Name, {transaction, Func}).

delete(Name) ->
    gen_server:call(Name, stop).
