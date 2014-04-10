-module(hostess_table_sup).
-behaviour(supervisor).
-export([init/1]).
-export([start_link/0]).
-export([add_worker/1]).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

add_worker(Name) ->
    supervisor:start_child(?MODULE, hostess_table:child_spec(Name)).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    Children = [
        {
            hostess_server,
            {hostess_server, start_link, []},
            transient, 5000, worker, [hostess_server]
        }
    ],
    {ok, { {one_for_one, 5, 10}, Children} }.
