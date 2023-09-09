#!/bin/bash
set -euxo pipefail
cd "$(dirname "$0")/"

__runtexshebang=../runtexshebang.lua
texfile=$(basename $0 .bash).tex
falsemsg='TeX-style shebang not found.'

trap testclean EXIT
testclean(){
    set +e
    rm ${texfile}
}

cat>${texfile}<<EOF
%%1
%%2
%%3
%%4
%%5
%%6
%%7
%%8
%%9
%%10
EOF

texshbmsg=$(texlua ${__runtexshebang} ${texfile} ||:)
test "${texshbmsg}" == "${falsemsg}"

## TeX-style shebang not found.
cat>${texfile}<<EOF
%%1
%%2
%%3
%%4
%%5
%%6
%%7
%%8
%%9
%%10
%%11
%%12
%%13
%%14
%%15
%%16
%%17
%%18
%%19
%%20
%#!echo This is a TeX-style shebang line.
EOF

texshbmsg=$(texlua ${__runtexshebang} ${texfile} ||:)
test "${texshbmsg}" == "${falsemsg}"

echo OK
