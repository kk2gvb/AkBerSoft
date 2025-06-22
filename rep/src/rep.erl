-module(rep).
-export([start/0, loop/2]).

start() ->
    application:start(chumak),
    {ok, Socket} = chumak:socket(rep),
    {ok, _Pid} = chumak:bind(Socket, tcp, "0.0.0.0", 5015),
    %% 10 сообщений, сделано только для демонстрации
    loop(Socket, 10),
    %% Остановка сокета, сделано также только для демонстрации
    gen_server:stop(Socket).

loop(_, 0) ->
    ok;

loop(Socket, Count) when Count > 0 ->
    {ok, Msg} = chumak:recv(Socket),
    io:format("Receive:~p~n", [Msg]),

    Reversed = lists:reverse(binary_to_list(Msg)),
    ReversedBin = list_to_binary(Reversed),

    timer:sleep(1000),
    chumak:send(Socket, ReversedBin),

    loop(Socket, Count - 1).
