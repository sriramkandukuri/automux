source ./testsetup.cfg

source ./automux.sh

automux_init
automux_on P1
automux_bg_exec \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P2
automux_bg_exec \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P3
automux_bg_exec_wait 1 \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P4
automux_bg_exec_wait 2 \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P5
automux_bg_exec_expect_prompt \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P6
automux_bg_exec_expect_prompt_out \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P6
automux_bg_exec_expect "\$ " \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P7
automux_bg_exec_out \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P8
automux_bg_exec_out \
    "echo TEST1 OK" \
    "rnp sri" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P1
automux_bg_exec_wait_out 2 \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "rnp sri" \
    "echo TEST3 OK"
automux_on P2
automux_bg_exec_wait_out 1 \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "rnp sri" \
    "echo TEST3 OK"
wait
automux_on P1
automux_exec \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P2
automux_exec \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P3
automux_exec_wait 1 \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P4
automux_exec_wait 2 \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P5
automux_exec_expect_prompt_out \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P6
automux_exec_expect_out "\$ " \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P5
automux_exec_expect_prompt \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P6
automux_exec_expect "\$ " \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P7
automux_exec_out \
    "rnp sri" \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P8
automux_exec_out \
    "echo TEST1 OK" \
    "rnp sri" \
    "echo TEST2 OK" \
    "echo TEST3 OK"
automux_on P1
automux_exec_wait_out 2 \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "rnp sri" \
    "echo TEST3 OK"
automux_on P2
automux_exec_wait_out 1 \
    "echo TEST1 OK" \
    "echo TEST2 OK" \
    "rnp sri" \
    "echo TEST3 OK"
automux_clean
