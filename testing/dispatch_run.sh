#!/bin/sh

LOG="log.txt"
>$LOG
for i in dispatch*; do
    echo >>$LOG
    echo "*********** Executing $i" >>$LOG
    echo "*********** Executing $i"
    echo >>$LOG

    ./$i 1>>$LOG 2>&1

    echo >>$LOG
    echo "********** Finished" >>$LOG
    echo >>$LOG
done
