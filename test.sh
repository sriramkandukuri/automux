source ./testsetup.cfg

source ./automux.sh

automux_init
automux_on P1
automux_exec \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P2
automux_exec \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P1
automux_exec_wait 5 \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P2
automux_exec_wait 10 \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P1
automux_exec_expect "\$ " \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P2
automux_exec_expect "\$ " \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P1
automux_exec_out \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P2
automux_exec_out \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P1
automux_exec_wait_out 5 \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P2
automux_exec_wait_out 10 \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_clean
