#!/bin/bash

#H # Introduction
#H
#H Automation tool using tmux and panes. Wrapper to some of the tmux commands to make simple 
#H automation scripts refer test.sh in this repo for reference.

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

_automux_panescfg()
{
    local pcount=1
    local wcount=1
    local winname=""
    if [ $MAX_PANES_PER_WINDOW -gt 0 ]; then
        winname="${WINNAME}_${wcount}"
    else
        winname="${WINNAME}"
    fi
    export CONSOLE_id=$SNAME:$winname.$pcount
    tmux rename-window $winname
    tmux setw pane-border-format "[#{@automux-panename} #P]"
    tmux set -p @automux-panename ${WINNAME}_CONSOLE
    local _atmx_iter=""
    for _atmx_iter in $PANES
    do
        _automux_prdbg "Opening pane with name $_atmx_iter"
        if [ $pcount == $MAX_PANES_PER_WINDOW ]; then
            pcount=1
            wcount=`expr $wcount + 1`
            winname=${WINNAME}_$wcount
            tmux new-window -n $winname
            tmux setw pane-border-format "[#{@automux-panename} #P]"
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
#H Prepare a config file taking ./testsetup.cfg as reference. Set all mandatory values there.
#H Then use below steps in your scripts
#H
#H
#H ```
#H source <configfile>
#H source <automux.sh>
#H ```
#H
#H Start using provided functions as per the need. All exec functions support multiple commands to 
#H execute on a pane, take test.sh as a reference

#H ## Automux Onetime functions

#H ### automux_init
#H
#H Very first function to call to enable automux infra and dont use it multiple times.
#H If you have multiple scripts to execute using this have a init script with this function
#H and source it, then you can use all scripts. its mandatory to source automux.sh in all scripts.
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

#H ### automux_clean
#H
#H Closes all opened panes, cleans all temporary files created by automux, run this after 
#H completing everything. As it closes every pane abruptly, close all open connections in panes
#H before calling this function
automux_clean()
{
    rm -rf $AUTOMUX_TEMPFILE
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
#H Use this function to change effective pane to execute all following automux functions
#H
#H > Params
#H > - $1 - pane name this should be the one from config PANES
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

#H ## Automux command executor functions

#H ### automux_exec
#H
#H execute given commands on selected pane using automux_on
#H
#H > Params
#H > - Command(s) to execute seperated as strings refer test.sh 
automux_exec()
{
    local _atmx_iter=""
    for _atmx_iter in "$@"
    do
        tmux send-keys $CURPANE "$_atmx_iter" Enter
        sleep $CURSLEEP
    done
    _automux_postexec
}

#H ### automux_exec_wait
#H
#H execute given commands on selected pane using automux_on
#H
#H > Params
#H > - $1 is seconds to wait till the command completes
#H > - Command(s) to execute seperated as strings refer test.sh 
automux_exec_wait()
{
    export CURSLEEP=$1
    shift
    automux_exec "$@"
}

#H ### automux_exec_expect
#H
#H execute given commands on selected pane using automux_on
#H
#H > Params
#H > - $1 is expect string we wait till it founds on selected pane
#H > - Command(s) to execute seperated as strings refer test.sh 
automux_exec_expect()
{
    local expstr="$1"
    local obtstr=""
    shift
    local _atmx_iter=""
    for _atmx_iter in "$@"
    do
        tmux pipe-pane $CURPANE "cat >> $AUTOMUX_TEMPFILE"
        tmux send-keys $CURPANE "$_atmx_iter" Enter
        obtstr=""
        while [ "$obtstr" != "$expstr" ]
        do
            obtstr=$(cat $AUTOMUX_TEMPFILE|tail -1)
        done
        tmux pipe-pane $CURPANE
        echo -ne > $AUTOMUX_TEMPFILE
    done
    _automux_postexec
}

#H ### automux_exec_out
#H
#H execute given commands on selected pane using automux_on and dumps output on console
#H
#H > Params
#H > - Command(s) to execute seperated as strings refer test.sh 
automux_exec_out()
{
    local _atmx_iter=""
    for _atmx_iter in "$@"
    do
        tmux pipe-pane $CURPANE "cat >> $AUTOMUX_TEMPFILE"
        tmux send-keys $CURPANE "$_atmx_iter" Enter
        sleep $CURSLEEP
        tmux pipe-pane $CURPANE
    done
    _automux_postexec
    cat $AUTOMUX_TEMPFILE
    echo -ne > $AUTOMUX_TEMPFILE
}

#H ### automux_exec_wait_out
#H
#H execute given commands on selected pane using automux_on and dumps output on console
#H
#H > Params
#H > - $1 sleep between every command
#H > - Command(s) to execute seperated as strings refer test.sh 
automux_exec_wait_out()
{
    export CURSLEEP=$1
    shift
    automux_exec_out "$@"
}
