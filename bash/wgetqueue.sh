#!/bin/bash

shopt -s nullglob
function dpid {
    cat "$DAEMON"
}

function daemonerror {
    pid=`cat "$DAEMON"`
    echo -n `date` >> $ELOG
    echo -n " $$ " >> $ELOG
    echo "$1 PID = $pid" >> $ELOG
    exit 255
}

function daemon {
    if [[ -f "$DAEMON" ]]; then
        daemonerror "Error: Daemon is already running"
        exit 255
    fi
    echo $$ > "$DAEMON"
    trap "" SIGHUP
    while true
    do
        for a in "$QPATH/requests"/*
        do
            url=`cat "$a"`
            rm "$a"
            wget -c "$url" 2> $ELOG
        done
        sleep 5
    done
}

function usage {
    echo "./wgetqueue.sh"
    echo "Flags"
    echo -e "\t-c\n\t\tCheck if daemon is running."
    echo -e "\t-k\n\t\tKill daemon."
    echo -e "\t-h\n\t\tPrint this help."
    echo ""
}

if [[ $# -eq 0 ]] || [[ $1 == "-h" ]]; then
    usage
    exit
fi

QPATH=$HOME/.nyaqueue
ELOG=$QPATH/error.log
DAEMON=$QPATH/daemonrunning

mkdir -p "$QPATH"
mkdir -p "$QPATH/requests"

if [[ $1 == "-c" ]]; then
    if [[ -f $DAEMON ]]; then
        pid=`dpid`
        echo "Daemon is running: PID = $pid"
    else
        echo "Daemon is not running."
    fi
    exit
fi

if [[ $1 == "-k" ]]; then
    if [[ -f $DAEMON ]]; then
        pid=`dpid`
        echo "Killing daemon: PID = $pid"
        kill -9 "$pid"
        rm -f $DAEMON
    else
        echo "Daemon is not running."
    fi
    exit
fi

if [[ $1 == "-d" ]]; then
    daemon
fi

for a in "$@"
do
    r=`mktemp --tmpdir="$QPATH/requests"`
    echo "$a" > "$r"
done
if [[ ! -f $DAEMON ]]; then
    bash ./wgetqueue.sh -d > /dev/null 2>&1 & disown
    echo "Daemon started: PID = $!"
fi
