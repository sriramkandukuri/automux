
# Introduction

Automation tool using tmux and panes. Wrapper to some of the tmux commands to make
automation scripts 

refer [test.sh](test.sh) for example

## Usage

Prepare a config file taking [testsetup.cfg](testsetup.cfg) as reference. Set all mandatory values.
Then use below steps in your scripts


```
source <configfile>
source <automux.sh>
```

Its mandatory to source `automux.sh` in all scripts.

Now you can call any of the below functions. `automux_*_exec_*` functions support multiple commands
as inputs which gets executed on any pane, take [test.sh](test.sh) as a reference



## Automux Onetime functions



### automux_init

This API enables automux infra and opens all the panes as per the config.


> Dont use it multiple times.
> This must be first function to call before calling any `automux_*` APIs


Calling this in an init script and souring it would be suggested if you have multiple scripts to
run using automux. This way all the config params are exported to environment to reuse.



### automux_clean

Closes all opened panes, cleans all temporary files created by automux, run this at last after 
completing everything. As it closes every pane abruptly, its upto user to kill processes or close
all open connections in any panes before calling this function

## Automux select pane functions

### automux_on

Use this function to change active pane, all following automux functions runs commands on the
selected pane using this function

> Params
> - $1 - pane name this should be the one from configuration variable PANES

## Naming convention of APIs
Keywords in APIs and their meaning

|Keyword| Description|
|---|---|
|`wait` | These APIs uses the given delay in between |
|`out` | These APIs dump output of commands on console |
|`expect` | These APIs run the given commands and expect given string in output |
|`bg` | These APIs run the given commands in background |

## Automux APIs
Below functions runs the commands on PANE selected by `automux_on` API

All APIs take one or more commands as space separated strings, these commands gets executed on 
selected pane refer [test.sh](test.sh) 


### automux_exec

execute given commands

> Params
> - List of Command(s) to execute.

### automux_play_keys

Send given keys one by one to target pane, usefull for minicom kind consoles
keys must be in tmux compatible format

> Params
> - List of Keys(s) to execute.

### automux_exec_wait

execute given commands with a given delay in between

> Params
> - $1 is delay in seconds to use after every command
> - List of Command(s) to execute.

### automux_exec_expect

execute given commands and waits untill expected string is 
obtained on last line of the output

NOTE: Use this when the given string is exact match at the end of output

> Params
> - $1 is expected string at the last line of the output
> - List of Command(s) to execute.

### automux_exec_expect_out

execute given commands and waits untill expected string is 
obtained on last line of the output

NOTE: Use this when the given string is exact match at the end of output

Also dumps output to console

> Params
> - $1 is expected string at the last line of the output
> - List of Command(s) to execute.

### automux_exec_expect_prompt

execute given commands and waits untill prompt is obtained

> Params
> - List of Command(s) to execute.

### automux_exec_expect_prompt_out

execute given commands and waits untill prompt is obtained

Also dumps output to current pane

> Params
> - List of Command(s) to execute.

### automux_exec_expect_substr

execute given commands and checks for given string is present at any place in last line of output

> Params
> - List of Command(s) to execute.

### automux_exec_expect_substr_out

execute given commands and checks for given string is present at any place in last line of output

Also dumps output to current pane

> Params
> - $1 is expected string at any place of the last line of the output
> - List of Command(s) to execute.

### automux_exec_findstr

execute given commands and waits till given string obtained any where in the output

> Params
> - $1 is expected string at any place of the last line of the output
> - List of Command(s) to execute.

### automux_exec_findstr_out

execute given commands and waits till given string obtained any where in the output

Also dumps output to current pane

> Params
> - $1 is expected string at any place of the whole output log
> - List of Command(s) to execute.

### automux_exec_out

execute given commands and dumps output on console

NOTE: Output gets printed after execution of all commands

> Params
> - $1 is expected string at any place of the whole output log
> - List of Command(s) to execute.

### automux_exec_wait_out

execute given commands with the given delay in between, and dumps output on console

NOTE: Output gets printed after execution of all commands

> Params
> - $1 is delay in seconds to use after every command
> - List of Command(s) to execute.

### automux_bg_exec_***

These are background variants of all above APIs
Whick execute given commands in background
Becarefull while exiting without completion of all invoked bg tasks.

Use `wait` command in any script which uses these APIs. This ensures the completion of all 
background tasks.

> Params
> - List of Command(s) to execute.

### automux_log_dump

dump the whole console histoy to specified file or stdout

NOTE: Output gets printed if no params given

> Params
> - $1 full path to file to store the log

### automux_log_clear

clear the console histoy
