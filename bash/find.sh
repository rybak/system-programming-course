#!/bin/bash
shopt -s dotglob nocaseglob

d="."
n="*"
tset=false
debug=false

if [ $# -gt 0 ]; then
    d=$1
    shift
fi

if [ ! -d $d ] && [ ! -f $d ]; then
    echo "$d is not a directory"
    exit 1
fi

while [ $# -gt 0 ]
do
    case "$1" in
    
    -iname) n=$2
            shift 2
            ;;
    -type)  t=$2
            shift 2
            tset=true
            ;;
    esac
done

function searchw {
    wd=$1
    wd=${wd/%\//}
    search $wd $2
}
defaultt="d"
#echo "iname=$n"
function search {
    wd=$1
    t="-${2:-$defaultt}"
    if [ $t $wd ]; then
        fn=${wd##*/}
        if [[ ${fn,,} == ${n,,} ]]; then
            echo $wd
        fi
    fi

    other=$defaultt
    if [ $tset = false ]; then other="-f"; fi

    for d in $wd/*
    do
        if [ $other $d ] && [ ! -d $d ]; then
             fn=${d##*/}
             if [[ ${fn,,} == ${n,,} ]]; then
                echo $d
             fi
        fi
    done

    for nd in $wd/*
    do
        if [ -d $nd ]; then
            search $nd $2
        fi
    done
}

searchw $d $t

