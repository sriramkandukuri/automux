source ./testsetup.cfg

source ./automux.sh

echo "" > /tmp/testlog

automux_init
echo "Running TEST at ${LINENO} : "
automux_on P1
automux_bg_exec \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P2
automux_bg_exec \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P3
automux_bg_exec_wait 1 \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P4
automux_bg_exec_wait 2 \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P5
automux_bg_exec_expect_prompt \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P6
automux_bg_exec_expect_prompt_out \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" >> /tmp/testlog
echo "Running TEST at ${LINENO} : "
automux_on P6
automux_bg_exec_expect "\$ " \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P7
automux_bg_exec_out \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P8
automux_bg_exec_out \
    "echo TEST${LINENO} OK" \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P1
automux_bg_exec_wait_out 2 \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "rnp sri" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P2
automux_bg_exec_wait_out 1 \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "rnp sri" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

wait
echo "Running TEST at ${LINENO} : "
automux_on P1
automux_exec \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P2
automux_exec \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P3
automux_exec_wait 1 \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P4
automux_exec_wait 2 \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P5
automux_exec_expect_prompt_out \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

automux_on P6
automux_exec_expect_out "\$ " \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P5
automux_exec_expect_prompt \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P6
automux_exec_expect "\$ " \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "
automux_on P7
automux_exec_out \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P8
automux_exec_out \
    "echo TEST${LINENO} OK" \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P1
automux_exec_wait_out 2 \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "rnp sri" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P2
automux_exec_wait_out 1 \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "rnp sri" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P7
automux_bg_exec_expect_substr_out "\$" \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P4
automux_bg_exec_expect_substr "\$" \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"

wait

echo "Running TEST at ${LINENO} : "
automux_on P5
automux_exec_expect_substr_out "\$" \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P4
automux_exec_expect_substr "\$" \
    "rnp sri" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "

echo "Running TEST at ${LINENO} : "
automux_on P7
automux_bg_exec_findstr_out "TEST" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P4
automux_bg_exec_findstr "TEST" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"

wait

echo "Running TEST at ${LINENO} : "
automux_on P5
automux_exec_findstr_out "TEST" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" >> /tmp/testlog

echo "Running TEST at ${LINENO} : "
automux_on P4
automux_exec_findstr "TEST" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK" \
    "echo TEST${LINENO} OK"
echo "Running TEST at ${LINENO} : "

echo "---------------------------- TEST LOG APIS ------------------------------------"
automux_on P3
automux_log_dump

automux_on P5
automux_log_dump /tmp/atmxtest
cat /tmp/atmxtest
rm -rf /tmp/atmxtest

automux_on P7
automux_log_clear

echo "---------------------------- CLOSE AUTOMUX ------------------------------------"
sleep 10
automux_clean
