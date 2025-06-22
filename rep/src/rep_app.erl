%%%-------------------------------------------------------------------
%% @doc rep public API
%% @end
%%%-------------------------------------------------------------------

-module(rep_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    rep_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
