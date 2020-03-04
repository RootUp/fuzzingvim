#!/usr/bin/env bash

echo -e "[+] Cloning VIM"
git clone https://github.com/vim/vim.git ; cd vim
echo "[+] Compiling VIM with AFLPlusPlus"
CC=afl-clang-fast CXX=afl-clang-fast++ ./configure --with-features=huge --enable-gui=none
export AFL_INST_RATIO=30 ; export AFL_HARDEN=1 ; make -j4 ; cd src
echo "[+] Feeding Seeds"
mkdir corpus ; mkdir output ;
echo "a*b\+\|[0-9]\|\d{1,9}" > corpus/1 ; echo "^\d{1,10}$" > corpus/2
echo "[+] Adding Dictionary"
wget https://raw.githubusercontent.com/vanhauser-thc/AFLplusplus/master/dictionaries/regexp.dict
echo "[+] Fuzzing VIM Regex Engine"
afl-fuzz -m none -x regexp.dict -i corpus -o output ./vim -u NONE -X -Z -e -s -S @@ -c ':qa!'
