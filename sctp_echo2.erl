-module(sctp_echo2).
-compile(export_all).

-include_lib("kernel/include/inet.hrl").
-include_lib("kernel/include/inet_sctp.hrl").

-define(T1(Msg),io:format("~p:~p ~p ~n",[?MODULE,?LINE,Msg])).
  
start() ->
      spawn(fun()->server({127,0,0,1}, 2015) end).
  
server([Host,Port]) when is_list(Host), is_list(Port) ->
      {ok, #hostent{h_addr_list = [IP|_]}} = inet:gethostbyname(Host),
      io:format("Start at ~p ~p ~n", [Host, IP]),
      server([IP, list_to_integer(Port)]).
  
server(IP, Port) when is_tuple(IP) orelse IP == any 
                                   orelse IP == loopback,
                        is_integer(Port) ->
                        
      {ok,S} = gen_sctp:open(Port, [{recbuf,65536},
                                    {ip,IP},
                                    %{dontroute, true},
                                    {sndbuf,65536}]),
                                    
      io:format("Listening on ~p:~p Socket=~p~n", [IP,Port,S]),
      io:format("~p:~p listen ~p ~n",[?MODULE,?LINE,gen_sctp:listen(S, true)]),
      server_loop(S).
  
server_loop(S) ->
      case gen_sctp:recv(S) of
      {error, Error} ->
          io:format("~p:~p SCTP RECV ERROR: ~p~n", [?MODULE,?LINE,Error]);
      Data ->
          io:format("Received: ~p~n", [Data]),
          Assoc=fetch_assoc(Data),
          io:format("Assoc: ~p~n", [Assoc]),
          try fetch_data(Data) of
           BData->gen_sctp:send(S,Assoc,0,
                                list_to_binary(atom_to_list(?MODULE)++":"++
                                               integer_to_list(?LINE)++ 
                                               " ECHO: "++binary_to_list(BData)))
          catch
          Err:Reason->io:format("~p:~p ~p ~n",[?MODULE,?LINE,{Err,Reason}])
          end

      end,
      server_loop(S). 
      
fetch_assoc({ok,{_IP,_Port,_L,{_Atom_Subj,{IP,Port},_ActionA,_Int2,Assoc}}})->Assoc;

fetch_assoc({ok,{_IP,_Int1,_L,{_AtomSubj,_Atom2,_Int2,_Int3,_Int4,Assoc}}})->Assoc;

%fetch_assoc({ok,{_IP,_Int1,_L,{_AtomSubj,_Atom2,_Int2,_Int3,_Int4,Assoc}}})->Assoc;

fetch_assoc({ok,{_IP, _Int1,[{_Atom,_Int2,_Int3,_L,Int4,_Int5,_Int6,_Int7,_Int8,Assoc}],_BinData}})->Assoc.

fetch_data({ok,{_IP, _Int1,[{_Atom,_Int2,_Int3,_L,Int4,_Int5,_Int6,_Int7,_Int8,_Assoc}],BinData}})->BinData.

% Bind socket to another Pid
% gen_sctp:controlling_process(Socket, Pid) 
