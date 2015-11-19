
simple SCTP echo on ERLANG with some number of SCTP data streams.

1) Compilation:
   erlc *.erl

2) Run in one erl session server:

 sctp_echo2:start().

3) Run in another erl session client code:

 sctp_cl:start().

