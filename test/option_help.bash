#!/bin/bash
set -euxo pipefail
cd "$(dirname "$0")/"

__runtexshebang=../runtexshebang.lua
whoamimsg=$(${__runtexshebang} --version)
texfile=$(basename $0 .bash).tex

trap testclean EXIT
testclean(){
    set +e
    rm ${texfile}
}

##
texlua ${__runtexshebang} --help
texlua ${__runtexshebang} -help
texlua ${__runtexshebang} -h

echo OK
