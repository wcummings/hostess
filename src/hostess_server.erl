-module(hostess_server).
-behaviour(gen_server).
-export([start_link/0, new_table/1]).
-export([init/1,
         code_change/3,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2
        ]).

-include("hostess.hrl").

-record(state, {pending_tables}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

new_table(Name) ->
    gen_server:call(?MODULE, {new_table, Name}).

%% ===================================================================
%% server callbacks
%% ===================================================================

init([]) ->
    {ok, #state{pending_tables = dict:new()}}.

handle_cast(stop, State) ->
    {stop, normal, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_call({new_table, Name}, _From, S) ->
    case add_table({new, Name}) of
        {error, _Reason} = E -> {reply, {ok, E}, S};
        Name -> {reply, {ok, Name}, S}
    end;

handle_call(_Msg, _From, State) ->
    {reply, {error, undef}, State}.

handle_info({'ETS-TRANSFER', Name, OldOwner, _Data}, #state{pending_tables = PendingTables} = S) ->
    {noreply, S#state{pending_tables = dict:append(OldOwner, Name, PendingTables)}};

handle_info({'EXIT', FromPid, _Reason}, #state{pending_tables = PendingTables} = S) ->
    Name = dict:fetch(FromPid, PendingTables),
    {ok, Name} = add_table(Name),
    {noreply, S#state{pending_tables = dict:erase(FromPid, PendingTables)}};

handle_info(_Msg, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ===================================================================
%% internal functions
%% ===================================================================

add_table({new, Name}) ->
    case ets:info(Name) of
        undefined ->
            Name = ets:new(Name, [named_table, public, {heir, self(), undefined}]),
            add_table(Name);
        _ ->
            {error, exists}
    end;

add_table(Name) ->
    {ok, Pid} = hostess_sup:add_worker(Name),
    link(Pid),
    ets:give_away(Name, Pid, undefined),
    {ok, Name}.
