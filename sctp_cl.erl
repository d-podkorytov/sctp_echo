-module(sctp_cl).
-compile(export_all).

-include_lib("kernel/include/inet.hrl").
-include_lib("kernel/include/inet_sctp.hrl").
 
start() ->
      spawn(fun()->client([localhost]) end). % or {127,0,0,1}
  
client([Host]) ->
      client(Host, 2015);
  
client([Host, Port]) when is_list(Host), is_list(Port) ->
      client(Host,list_to_integer(Port)),
      init:stop().
  
client(Host, Port) when is_integer(Port) ->
      {ok,S}     = gen_sctp:open(),
      {ok,Assoc} = gen_sctp:connect
          (S, Host, Port, [{sctp_initmsg,#sctp_initmsg{num_ostreams=5}}]),
      io:format("Connection Successful, Assoc=~p~n", [Assoc]),

      io:format("~p:~p ~p ~n",[?MODULE,?LINE,gen_sctp:send(S, Assoc, 0, <<"Test 0">>)]),
      timer:sleep(100),
      io:format("~p:~p ~p ~n",[?MODULE,?LINE,gen_sctp:recv(S,500) ]),
      
      io:format("~p:~p ~p ~n",[?MODULE,?LINE,gen_sctp:send(S, Assoc, 2, <<"Test 2">>)]),
      timer:sleep(100),

      io:format("~p:~p ~p ~n",[?MODULE,?LINE,gen_sctp:recv(S,500) ]),
      timer:sleep(100),

      io:format("~p:~p ~p ~n",[?MODULE,?LINE,gen_sctp:abort(S, Assoc)]),
            
      timer:sleep(100),
      gen_sctp:close(S).   


