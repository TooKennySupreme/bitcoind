#!/bin/bash

if [ ! -f ~/.bitcoin/bitcoin.conf ]; then
    echo "ERROR: ~/.bitcoin/bitcoin.conf not found." 1>&2

    if [ "`id -u`" = "0" ]; then
        echo "NOTICE: This script DOES NOT need to be run as root." 1>&2
    fi

    exit 1
fi

if [ "$*" == "--poll" ]; then
    i=0; j=0
    web_count=`wget -O - http://blockchain.info/q/getblockcount 2>/dev/null`
    while [ 0 -eq 0 ]; do
        local_count=`bitcoin-cli getblockcount 2>&1`
        if [ "$?" -gt 0 ]; then
            echo "ERROR: Can't connect to bitcoind. Is it running?" 1>&2
            exit 1
        fi
        if [ $i = 10 ]; then
            web_count=`wget -O - http://blockchain.info/q/getblockcount 2>/dev/null`
            i=0
        fi

        echo -ne "\r\033[KDownloaded:\t${local_count} of ${web_count}\t\t( $((${local_count} * 100 / ${web_count}))% )"

        if [ $j -ge 1 ]; then   echo -n " .";           else echo -ne "  "; fi
        if [ $j -ge 2 ]; then   echo -n ".";            else echo -ne " ";  fi
        if [ $j -ge 3 ]; then   echo -n ".";    j=0;    else echo -ne " ";  fi
        echo -n " "

        sleep 3
        i=$(($i +1))
        j=$(($j +1))
    done
else
    local_count=`bitcoin-cli getblockcount 2>&1`
    if [ "$?" -gt 0 ]; then
        echo "ERROR: Can't connect to bitcoind. Is it running?" 1>&2
        exit 1
    fi
    web_count=`wget -O - http://blockchain.info/q/getblockcount 2>/dev/null`

    echo -e "Downloaded:\t${local_count} of ${web_count}\t\t( $((${local_count} * 100 / ${web_count}))% )"
fi

