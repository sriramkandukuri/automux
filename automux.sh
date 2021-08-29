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
    if [ "$AUTOMUX_DEBUG" = "Y" ]
    then
        _automux_print DBG "$@"
    fi
}

_automux_prerr()
{
    _automux_print ERR "$@"
}

_automux_chkrename_pane()
{
    local curname=$(tmux list-panes -F "#P:#T"|grep "^${CURPANENUM}:"|cut -d":" -f2-)
    _automux_prdbg "Renaming \"$curname\" to \"$CURPANENAME\""
    if [ "$curname" != "$CURPANENAME" ]
    then
        tmux select-pane $CURPANE -T $CURPANENAME
    fi
}

_automux_postexec()
{
    _automux_chkrename_pane
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
    return 0
}

_automux_wincfg()
{
    tmux rename-window $WINNAME
}

_automux_panescfg()
{
    tmux select-pane -T ${WINNAME}_CONSOLE
    for i in $PANES
    do
        _automux_prdbg "Opening pane with name $i"
        tmux split-window
        tmux select-pane -T $i
        tmux select-layout tiled
    done
    for i in $(tmux list-panes -F "#T_id=#P")
    do
        export "$i"
    done
    tmux select-pane -t 1
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
#H execute on a pane

#H ## Automux functions

#H ### automux_on
#H
#H Use this function to change effective pane to execute all following automux functions
#H
#H $1 - pane name this should be the one from config PANES
automux_on()
{
    if [ "$1" == "" ] 
    then
        _automux_prerr "Requires pane name as argument"
        return -1
    fi
    
    local var="${1}_id"
    var=$(printenv $var)

    if [ "$var" != "" ]
    then
        export CURPANE="-t $PFX.$var"
        export CURPANENUM="$var"
        export CURPANENAME="$1"
    else
        _automux_prerr "Pane name invalid"
        return -1
    fi
    _automux_prdbg "$CURPANE"
}

#H ### automux_exec
#H
#H execute given commands on selected pane using automux_on
automux_exec()
{
    for i in "$@"
    do
        tmux send-keys $CURPANE "$i" Enter
        sleep $CURSLEEP
    done
    _automux_postexec
}

#H ### automux_exec_wait
#H
#H execute given commands on selected pane using automux_on
#H
#H $1 is seconds to wait till the command completes
automux_exec_wait()
{
    export CURSLEEP=$1
    shift
    automux_exec "$@"
    _automux_postexec
}

#H ### automux_exec_expect
#H
#H execute given commands on selected pane using automux_on
#H
#H $1 is expect string we wait till it founds on selected pane
automux_exec_expect()
{
    local expstr="$1"
    local obtstr=""
    shift
    for i in "$@"
    do
        tmux pipe-pane $CURPANE "cat >> $AUTOMUX_TEMPFILE"
        tmux send-keys $CURPANE "$i" Enter
        obtstr=""
        while [ "$obtstr" != "$expstr" ]
        do
            obtstr=$(cat $AUTOMUX_TEMPFILE|tail -1)
            sleep $DEF_SLEEP
        done
        tmux pipe-pane $CURPANE
        echo -ne > $AUTOMUX_TEMPFILE
    done
    _automux_postexec
}

#H ### automux_exec_out
#H
#H execute given commands on selected pane using automux_on and dumps output on console
automux_exec_out()
{
    for i in "$@"
    do
        tmux pipe-pane $CURPANE "cat >> $AUTOMUX_TEMPFILE"
        tmux send-keys $CURPANE "$i" Enter
        sleep $CURSLEEP
        tmux pipe-pane $CURPANE
        cat $AUTOMUX_TEMPFILE
        echo -ne > $AUTOMUX_TEMPFILE
    done
    _automux_postexec
}

#H ### automux_exec_wait_out
#H
#H execute given commands on selected pane using automux_on and dumps output on console
#H
#H $1 sleep between every command
automux_exec_wait_out()
{
    export CURSLEEP=$1
    shift
    automux_exec_out "$@"
    _automux_postexec
}

#H ### automux_init
#H
#H Very first function to call to enable automux infra
automux_init()
{
    SNAME=$(tmux display-message -p "#S")
    if [ "$WINNAME" == "" ]
    then
        export WINNAME="AUTOMUX"
    fi
    PFX="$SNAME:$WINNAME"
    if [ "$DEF_SLEEP" == "" ]
    then
        export DEF_SLEEP=1
    fi
    export CURSLEEP=$DEF_SLEEP

    _automux_validate || exit -1
    _automux_wincfg
    _automux_panescfg
    export AUTOMUX_LOADED=1
    export AUTOMUX_TEMPFILE=$(mktemp)
}

#H ### automux_clean
#H
#H cleans all temporary files created by automux, run this after completing everything
automux_clean()
{
    rm -rf $AUTOMUX_TEMPFILE
    tmux kill-pane -a
}
