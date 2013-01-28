-module(hostess_table).
-behaviour(gen_server).
-export([start_link/1, child_spec/1]).
-export([init/1,
         code_change/3,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2
        ]).

-include("hostess.hrl").

%% ===================================================================
%% API functions
%% ===================================================================

start_link(Name) ->
    gen_server:start_link({local, Name}, ?MODULE, [Name], []).

child_spec(Name) ->
    {
        Name,
        {hostess_table, start_link, [Name]},
        temporary, 5000, worker, [hostess_table]
    }.

%% ===================================================================
%% server callbacks
%% ===================================================================

init([Name]) ->
    {ok, #table_state{name = Name}}.

handle_cast(stop, State) ->
    {stop, normal, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_call({transaction, Func}, _From, #table_state{name = Name} = S) ->
    RV = Func(Name),
    {reply, {ok, RV}, S};

handle_call(_Msg, _From, State) ->
    {reply, {error, undef}, State}.

handle_info({'ETS-TRANSFER', Name, _OldOwner, _Data}, S) ->
    {noreply, S#table_state{table = Name}};

handle_info(_Msg, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
