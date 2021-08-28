
# Introduction



Automation tool using tmux and panes. Wrapper to some of the tmux commands to make simple 

automation scripts refer test.sh in this repo for reference.

## Usage



Prepare a config file taking ./testsetup.cfg as reference. Set all mandatory values there.

Then use below steps in your scripts





```

source <configfile>

source <automux.sh>

```



Start using provided functions as per the need. All exec functions support multiple commands to 

execute on a pane

## Automux functions

### automux_on



Use this function to change effective pane to execute all following automux functions



$1 - pane name this should be the one from config PANES

### automux_exec()



execute given commands on selected pane using automux_on

### automux_exec_wait()



execute given commands on selected pane using automux_on



$1 is seconds to wait till the command completes

### automux_exec_expect



execute given commands on selected pane using automux_on



$1 is expect string we wait till it founds on selected pane

### automux_exec_out



execute given commands on selected pane using automux_on and dumps output on console

### automux_exec_wait_out



execute given commands on selected pane using automux_on and dumps output on console



$1 sleep between every command

### automux_init



Very first function to call to enable automux infra

### automux_clean



cleans all temporary files created by automux, run this after completing everything
