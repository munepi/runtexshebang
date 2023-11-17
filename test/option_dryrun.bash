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
falsemsg="${whoamimsg}
No filename argument given, exiting."
texshbmsg=$(texlua ${__runtexshebang} --dry-run ||:)
test "${texshbmsg}" == "${falsemsg}"
texshbmsg=$(texlua ${__runtexshebang} -dry-run ||:)
test "${texshbmsg}" == "${falsemsg}"

##
truemsg="${whoamimsg}
texlua"
cat>${texfile}<<EOF
%#!texlua
EOF

texshbmsg=$(texlua ${__runtexshebang} --dry-run ${texfile})
test "${texshbmsg}" == "${truemsg}"

echo OK
