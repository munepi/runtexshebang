#!/bin/bash
set -euxo pipefail
cd "$(dirname "$0")/"

__runtexshebang="$(dirname "$0")/"../runtexshebang.lua
texfile=$(basename $0 .bash).tex

trap testclean EXIT
testclean(){
    set +e
    rm ${texfile}
}

##
truemsg='This is a TeX-style shebang line.'
cat>${texfile}<<EOF
%#!echo This is a TeX-style shebang line.
EOF

texshbmsg=$(texlua ${__runtexshebang} ${texfile})
test "${texshbmsg}" == "${truemsg}"


##
truemsg='TeX-style shebang: line 2'
cat>${texfile}<<EOF
% #!echo TeX-style shebang: line 1
%#!echo TeX-style shebang: line 2
EOF

texshbmsg=$(texlua ${__runtexshebang} ${texfile})
test "${texshbmsg}" == "${truemsg}"


##
truemsg='No script file given'
cat>${texfile}<<EOF
%#!texlua
EOF

texshbmsg=$(texlua ${__runtexshebang} ${texfile})
test "${texshbmsg}" == "${truemsg}"

echo OK
