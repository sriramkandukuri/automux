#!/bin/bash

#H # Introduction
#H
#H Automation tool using tmux and panes. Wrapper to some of the tmux commands to make
#H automation scripts 
#H 
#H refer [test.sh](test.sh) for example

SED_CMD="sed -u -e $'s,[\x01-\x1F\x7F][[0-9;]*[a-zA-Z],,g' -e 's/\x0//g'"

_automux_print()
{
    local idx=2
    [ "$3" != "" ] && idx=`expr $idx + $3`
    echo "[$1:${FUNCNAME[$idx]}] $2"
}

_automux_prdbg()
{
    if [ "$AUTOMUX_DEBUG" == "Y" ]
    then
        _automux_print DBG "$@"
    fi
}

_automux_prerr()
{
    _automux_print ERR "$@"
}

_automux_postexec()
{
    export CURSLEEP=$DEF_SLEEP
}

_automux_validate()
{
    local cur_pane_cnt=$(tmux list-panes | wc -l)
    if [ "$AUTOMUX_LOADED" != 1 ] && [ $cur_pane_cnt != 1 ]
    then
        _automux_prerr "Only one pane is expected to run automux initially" 1
        return -1
    fi
    local panes_count_1=$(echo $PANES|tr " " "\n"|sort|wc -l)
    local panes_count_2=$(echo $PANES|tr " " "\n"|sort -u|wc -l)
    if [ $panes_count_2 != $panes_count_1 ]; then
        _automux_prerr "Duplicate pane names not allowed" 1
        return -1
    fi
    return 0
}

_automux_winprops()
{
    tmux setw pane-border-format "[#{@automux-panename} #P]"
    tmux setw -g pane-base-index 1
    tmux setw -g pane-border-status bottom
}

_automux_panescfg()
{
    local pcount=1
    local wcount=1
    local winname=""
    tmux set -p @automux-panename ${WINNAME}_CONSOLE
    if [ $MAX_PANES_PER_WINDOW -gt 0 ]; then
        winname="${WINNAME}_${wcount}"
    else
        winname="${WINNAME}"
    fi
    export CONSOLE_id=$SNAME:$winname.$pcount
    tmux rename-window $winname
    _automux_winprops
    local _atmx_iter=""
    for _atmx_iter in $PANES
    do
        _automux_prdbg "Opening pane with name $_atmx_iter"
        if [ $pcount == $MAX_PANES_PER_WINDOW ]; then
            pcount=1
            wcount=`expr $wcount + 1`
            winname=${WINNAME}_$wcount
            tmux new-window -n $winname
            _automux_winprops
        else
            pcount=`expr $pcount + 1`
            tmux split-window
            tmux select-layout tiled
        fi
        tmux set -p @automux-panename "$_atmx_iter"
        local tmp="${_atmx_iter}_id"
        export "${tmp}=$SNAME:$winname.$pcount"
        export PANES_LIST="$tmp $PANES_LIST"
        _automux_prdbg "$tmp $(printenv $tmp)"
        _automux_prdbg "$PANES_LIST"
    done
    tmux select-pane -t $CONSOLE_id
}

#H ## Usage
#H
#H Prepare a config file taking [testsetup.cfg](testsetup.cfg) as reference. Set all mandatory values.
#H Then use below steps in your scripts
#H
#H
#H ```
#H source <configfile>
#H source <automux.sh>
#H ```
#H
#H Its mandatory to source `automux.sh` in all scripts.
#H
#H Now you can call any of the below functions. `automux_*_exec_*` functions support multiple commands
#H as inputs which gets executed on any pane, take [test.sh](test.sh) as a reference
#H

#H
#H ## Automux Onetime functions
#H

#H
#H ### automux_init
#H
#H This API enables automux infra and opens all the panes as per the config.
#H

#H
#H > Dont use it multiple times.
#H > This must be first function to call before calling any `automux_*` APIs
#H

#H
#H Calling this in an init script and souring it would be suggested if you have multiple scripts to
#H run using automux. This way all the config params are exported to environment to reuse.
#H
automux_init()
{
    export SNAME=$(tmux display-message -p "#S")
    if [ "$WINNAME" == "" ]
    then
        export WINNAME="AUTOMUX"
    fi
    if [ "$DEF_SLEEP" == "" ]
    then
        export DEF_SLEEP=1
    fi
    export CURSLEEP=$DEF_SLEEP
    if [ "$MAX_PANES_PER_WINDOW" == "" ]; then
        export MAX_PANES_PER_WINDOW=0 
    fi

    _automux_validate || exit -1
    _automux_panescfg
    export AUTOMUX_LOADED=1
    export AUTOMUX_TEMPFILE=$(mktemp)
}

#H
#H ### automux_clean
#H
#H Closes all opened panes, cleans all temporary files created by automux, run this at last after 
#H completing everything. As it closes every pane abruptly, its upto user to kill processes or close
#H all open connections in any panes before calling this function
automux_clean()
{
    rm -rf /tmp/automux_* 
    local _atmx_iter=""
    for _atmx_iter in $PANES_LIST
    do
        _automux_prdbg "$_atmx_iter $(printenv $_atmx_iter)"
        tmux kill-pane -t $(printenv $_atmx_iter)
    done
    export PANES_LIST=""
}

#H ## Automux select pane functions

#H ### automux_on
#H
#H Use this function to change active pane, all following automux functions runs commands on the
#H selected pane using this function
#H
#H > Params
#H > - $1 - pane name this should be the one from configuration variable PANES
automux_on()
{
    if [ "$1" == "" ] 
    then
        _automux_prerr "Requires pane name as argument"
        return -1
    fi
    
    local pane="${1}_id"
    local paneid=$(printenv $pane)
    _automux_prdbg "Pane id is $paneid"

    if [ "$paneid" != "" ]
    then
        export CURPANEID="$paneid"
        export CURPANE="-t $paneid"
        export CURPANENUM=$(echo $paneid | cut -d"." -f2)
        export CURPANENAME="$1"
    else
        _automux_prerr "Pane name invalid"
        return -1
    fi
    _automux_prdbg "$CURPANE"
}

#H ## Naming convention of APIs

#H Keywords in APIs and their meaning
#H
#H |Keyword| Description|
#H |---|---|
#H |`wait` | These APIs uses the given delay in between |
#H |`out` | These APIs dump output of commands on console |
#H |`expect` | These APIs run the given commands and expect given string in output |
#H |`bg` | These APIs run the given commands in background |

#H ## Automux APIs

#H Below functions runs the commands on PANE selected by `automux_on` API
#H
#H All APIs take one or more commands as space separated strings, these commands gets executed on 
#H selected pane refer [test.sh](test.sh) 
#H

#H ### automux_exec
#H
#H execute given commands
#H
#H > Params
#H > - List of Command(s) to execute.
automux_exec()
{
    local curpane=$CURPANE
    local cursleep=$CURSLEEP
    local _atmx_iter=""
    for _atmx_iter in "$@"
    do
        tmux send-keys $curpane "$_atmx_iter" Enter
        sleep $cursleep
    done
    _automux_postexec
}

#H ### automux_play_keys
#H
#H Send given keys one by one to target pane, usefull for minicom kind consoles
#H keys must be in tmux compatible format
#H
#H > Params
#H > - List of Keys(s) to execute.
automux_play_keys()
{
    local curpane=$CURPANE
    local cursleep=$CURSLEEP
    local _atmx_iter=""
    for _atmx_iter in "$@"
    do
        tmux send-keys $curpane "$_atmx_iter"
        sleep $cursleep
    done
    _automux_postexec
}

#H ### automux_exec_wait
#H
#H execute given commands with a given delay in between
#H
#H > Params
#H > - $1 is delay in seconds to use after every command
#H > - List of Command(s) to execute.
automux_exec_wait()
{
    export CURSLEEP=$1
    shift
    automux_exec "$@"
}

_automux_exec_expect()
{
    local curpane=$CURPANE
    local cursleep=$CURSLEEP
    local expout=""
    local explogic=""
    read expout explogic <<< $(echo "$1" | sed -e 's/-/ /g')
    shift
    local expstr=""
    local obtstr=""
    local _atmx_iter=""
    local curpname=$CURPANENAME
    local tmpf=$(mktemp -t "automux_${curpname}_XXXXXX")
    tmux pipe-pane $curpane "cat >> $tmpf"
    retrycnt=1000
    
    if [ "$explogic" != "prompt" ];then
        expstr=$1
        shift
    else
        tmux send-keys $curpane Enter
        sleep 1
        expstr=$(tail -1 $tmpf | eval $SED_CMD)
    fi

    for _atmx_iter in "$@"
    do
        tmux send-keys $curpane "$_atmx_iter" Enter
        sleep $DEF_SLEEP
        obtstr=""
        while true
        do
            obtstr=$(tail -1 $tmpf | eval $SED_CMD)
            retrycnt=`expr $retrycnt - 1`

            # if [ $retrycnt -eq 0 ]; then
            #     _automux_prerr "expstr($expstr) obtstr($obtstr)"
            #     retrycnt=1000
            # fi
            case $explogic in
                exactend|prompt)
                    if [ "$obtstr" = "$expstr" ]; then
                        break
                    fi
                    ;;
                substrend)
                    if [[ "$obtstr" == *"$expstr"* ]]; then
                        break
                    fi
                    ;;
                findlog)
                    if grep -qs "$expstr" $tmpf; then
                        break
                    fi
                    ;;
            esac
        done
    done
    if [ "$expout" = "Y" ]; then
        cat $tmpf | eval $SED_CMD
    fi
    tmux pipe-pane $curpane
    rm -rf $tmpf
    _automux_postexec
}
#H ### automux_exec_expect
#H
#H execute given commands and waits untill expected string is 
#H obtained on last line of the output
#H
#H NOTE: Use this when the given string is exact match at the end of output
#H
#H > Params
#H > - $1 is expected string at the last line of the output
#H > - List of Command(s) to execute.
automux_exec_expect()
{
    _automux_exec_expect N-exactend "$@"
}

#H ### automux_exec_expect_out
#H
#H execute given commands and waits untill expected string is 
#H obtained on last line of the output
#H
#H NOTE: Use this when the given string is exact match at the end of output
#H
#H Also dumps output to console
#H
#H > Params
#H > - $1 is expected string at the last line of the output
#H > - List of Command(s) to execute.
automux_exec_expect_out()
{
    _automux_exec_expect Y-exactend "$@"
}

#H ### automux_exec_expect_prompt
#H
#H execute given commands and waits untill prompt is obtained
#H
#H > Params
#H > - List of Command(s) to execute.
automux_exec_expect_prompt()
{
    _automux_exec_expect N-prompt "$@"
}

#H ### automux_exec_expect_prompt_out
#H
#H execute given commands and waits untill prompt is obtained
#H
#H Also dumps output to current pane
#H
#H > Params
#H > - List of Command(s) to execute.
automux_exec_expect_prompt_out()
{
    _automux_exec_expect Y-prompt "$@"
}

#H ### automux_exec_expect_substr
#H
#H execute given commands and checks for given string is present at any place in last line of output
#H
#H > Params
#H > - List of Command(s) to execute.
automux_exec_expect_substr()
{
    _automux_exec_expect N-substrend "$@"
}

#H ### automux_exec_expect_substr_out
#H
#H execute given commands and checks for given string is present at any place in last line of output
#H
#H Also dumps output to current pane
#H
#H > Params
#H > - $1 is expected string at any place of the last line of the output
#H > - List of Command(s) to execute.
automux_exec_expect_substr_out()
{
    _automux_exec_expect Y-substrend "$@"
}

#H ### automux_exec_findstr
#H
#H execute given commands and waits till given string obtained any where in the output
#H
#H > Params
#H > - $1 is expected string at any place of the last line of the output
#H > - List of Command(s) to execute.
automux_exec_findstr()
{
    _automux_exec_expect N-findlog "$@"
}

#H ### automux_exec_findstr_out
#H
#H execute given commands and waits till given string obtained any where in the output
#H
#H Also dumps output to current pane
#H
#H > Params
#H > - $1 is expected string at any place of the whole output log
#H > - List of Command(s) to execute.
automux_exec_findstr_out()
{
    _automux_exec_expect Y-findlog "$@"
}

#H ### automux_exec_out
#H
#H execute given commands and dumps output on console
#H
#H NOTE: Output gets printed after execution of all commands
#H
#H > Params
#H > - $1 is expected string at any place of the whole output log
#H > - List of Command(s) to execute.
automux_exec_out()
{
    local curpane=$CURPANE
    local cursleep=$CURSLEEP
    local _atmx_iter=""
    local curpname=$CURPANENAME
    local tmpf=$(mktemp -t "automux_${curpname}_XXXXXX")
    tmux pipe-pane $curpane "cat >> $tmpf"
    for _atmx_iter in "$@"
    do
        tmux send-keys $curpane "$_atmx_iter" Enter
        sleep $cursleep
    done
    _automux_postexec
    tmux pipe-pane $curpane
    cat $tmpf | eval $SED_CMD
    rm -rf $tmpf
}

#H ### automux_exec_wait_out
#H
#H execute given commands with the given delay in between, and dumps output on console
#H
#H NOTE: Output gets printed after execution of all commands
#H
#H > Params
#H > - $1 is delay in seconds to use after every command
#H > - List of Command(s) to execute.
automux_exec_wait_out()
{
    export CURSLEEP=$1
    shift
    automux_exec_out "$@"
}

#H ### automux_bg_exec_***
#H
#H These are background variants of all above APIs
#H Whick execute given commands in background
#H Becarefull while exiting without completion of all invoked bg tasks.
#H
#H Use `wait` command in any script which uses these APIs. This ensures the completion of all 
#H background tasks.
#H
#H > Params
#H > - List of Command(s) to execute.
automux_bg_exec()
{
    automux_exec "$@" &
}
automux_bg_exec_wait()
{ 
    automux_exec_wait "$@" &
}
automux_bg_exec_expect_prompt_out()
{ 
    automux_exec_expect_prompt_out "$@" &
}
automux_bg_exec_expect_prompt()
{ 
    automux_exec_expect_prompt "$@" &
}
automux_bg_exec_expect_substr_out()
{ 
    automux_exec_expect_substr_out "$@" &
}
automux_bg_exec_expect_substr()
{ 
    automux_exec_expect_substr "$@" &
}
automux_bg_exec_findstr_out()
{ 
    automux_exec_findstr_out "$@" &
}
automux_bg_exec_findstr()
{ 
    automux_exec_findstr "$@" &
}
automux_bg_exec_expect_out()
{ 
    automux_exec_expect_out "$@" &
}
automux_bg_exec_expect()
{ 
    automux_exec_expect "$@" &
}
automux_bg_exec_out()
{
    automux_exec_out "$@" &
}
automux_bg_exec_wait_out()
{
    automux_exec_wait_out "$@" &
}

#H ### automux_log_dump
#H
#H dump the whole console histoy to specified file or stdout
#H
#H NOTE: Output gets printed if no params given
#H
#H > Params
#H > - $1 full path to file to store the log
automux_log_dump()
{
    local curpane=$CURPANE
    local cursleep=$CURSLEEP
    local curpname=$CURPANENAME
    local tmpf=$(mktemp -t "automux_${curpname}_XXXXXX")
    tmux capture-pane -CNp $curpane -S - > $tmpf
    _automux_postexec
    echo $1
    if [ -n "$1" ]; then
        cp $tmpf $1
    else
        cat $tmpf
    fi
    rm -rf $tmpf
}

#H ### automux_log_clear
#H
#H clear the console histoy
automux_log_clear()
{
    local curpane=$CURPANE
    tmux clear-history $curpane
    _automux_postexec
}
