-module(hostess_sup).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1]).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    Children = [
        {
            hostess_server,
            {hostess_server, start_link, []},
            permanent, 5000, worker, [hostess_server]
        }
    ],
    {ok, { {one_for_one, 5, 10}, Children} }.
