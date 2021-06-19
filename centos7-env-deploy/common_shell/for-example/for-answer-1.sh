#!/bin/bash
mkdir -p /oldboy && cd /oldboy 
for filenum in `seq 100`
do
        touch oldboy-$filenum
done
