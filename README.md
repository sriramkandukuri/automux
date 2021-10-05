
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
execute on a pane, take test.sh as a reference

## Automux Onetime functions

### automux_init

Very first function to call to enable automux infra and dont use it multiple times.
If you have multiple scripts to execute using this have a init script with this function
and source it, then you can use all scripts. its mandatory to source automux.sh in all scripts.

### automux_clean

Closes all opened panes, cleans all temporary files created by automux, run this after 
completing everything. As it closes every pane abruptly, close all open connections in panes
before calling this function

## Automux select pane functions

### automux_on

Use this function to change effective pane to execute all following automux functions

> Params
> - $1 - pane name this should be the one from config PANES

## Automux command executor functions

### automux_exec

execute given commands on selected pane using automux_on

> Params
> - Command(s) to execute seperated as strings refer test.sh 

### automux_exec_wait

execute given commands on selected pane using automux_on

> Params
> - $1 is seconds to wait till the command completes
> - Command(s) to execute seperated as strings refer test.sh 

### automux_exec_expect

execute given commands on selected pane using automux_on and waits untill expected string is 
obtained on last line of the output

> Params
> - $1 is expect string we wait till it founds on selected pane
> - Command(s) to execute seperated as strings refer test.sh 

### automux_exec_expect_out

execute given commands on selected pane using automux_on and waits untill expected string is 
obtained on last line of the output
Also dumps output to current pane

> Params
> - $1 is expect string we wait till it founds on selected pane
> - Command(s) to execute seperated as strings refer test.sh 

### automux_exec_expect_prompt

execute given commands on selected pane using automux_on and checks for prompt

> Params
> - Command(s) to execute seperated as strings refer test.sh 

### automux_exec_expect_prompt_out

execute given commands on selected pane using automux_on and checks for prompt 
Also dumps output to current pane

> Params
> - Command(s) to execute seperated as strings refer test.sh 

### automux_exec_expect_substr

execute given commands on selected pane using automux_on and checks for given string 
is present in lastline of output

> Params
> - Command(s) to execute seperated as strings refer test.sh 

### automux_exec_expect_substr_out

execute given commands on selected pane using automux_on and checks for given string 
is present in lastline of output
Also dumps output to current pane

> Params
> - Command(s) to execute seperated as strings refer test.sh 

### automux_exec_findstr

execute given commands on selected pane using automux_on and checks for given string 
is present in lastline of output

> Params
> - Command(s) to execute seperated as strings refer test.sh 

### automux_exec_findstr_out

execute given commands on selected pane using automux_on and checks for given string 
is present in lastline of output
Also dumps output to current pane

> Params
> - Command(s) to execute seperated as strings refer test.sh 

### automux_exec_out

execute given commands on selected pane using automux_on and dumps output on console

> Params
> - Command(s) to execute seperated as strings refer test.sh 

### automux_exec_wait_out

execute given commands on selected pane using automux_on and dumps output on console

> Params
> - $1 sleep between every command
> - Command(s) to execute seperated as strings refer test.sh 

### automux_bg_exec_***

Similar to all exec commands but executes in background
Becarefull while exiting without waiting all invoked bg tasks.

> Params
> - Command(s) to poss to respective exec functions. refert test.sh 
