#!/bin/bash

var_macaroonpath="/home/pi/.lnd/readonly.macaroon"
var_tlscertpath="/home/pi/.lnd/tls.cert"
var_rpcserver="192.168.192.10"
var_lastinvoice="/home/pi/Lightning-GrepCandy/lastinvoice.txt"
var_satoshi=10
var_seconds=5
#rhash=$(lncli --network=testnet --macaroonpath $var_macaroonpath --tlscertpath $var_tlscertpath --rpcserver $var_rpcserver listinvoices --max_invoices 1 | grep r_hash | cut -d '"' -f 4)
lncli --network=testnet --macaroonpath $var_macaroonpath --tlscertpath $var_tlscertpath --rpcserver $var_rpcserver listinvoices --max_invoices 1 > $var_lastinvoice
rhash=$(cat $var_lastinvoice | grep r_hash | cut -d '"' -f 4)
settledate=$(cat $var_lastinvoice | grep settle_date | cut -d '"' -f 4)
account=0
checktime=$(date '+%s')

while true
do
oldrhash=$rhash
oldsettledate=$settledate

lncli --network=testnet --macaroonpath $var_macaroonpath --tlscertpath $var_tlscertpath --rpcserver $var_rpcserver listinvoices --max_invoices 1 > $var_lastinvoice

openstate='OPEN'
state=$(cat $var_lastinvoice | grep state | cut -d '"' -f 4)
if [ "$state" != "$openstate" ]
#sat=$(cat $var_lastinvoice | grep amt_paid_sat | cut -d '"' -f 4)
#rhash=$(cat $var_lastinvoice | grep r_hash | cut -d '"' -f 4)
#settledate=$(cat $var_lastinvoice | grep settle_date | cut -d '"' -f 4)
then
    echo "######STATE-BEDINGUNG#######"
    sat=$(cat $var_lastinvoice | grep amt_paid_sat | cut -d '"' -f 4)
    rhash=$(cat $var_lastinvoice | grep r_hash | cut -d '"' -f 4)
    settledate=$(cat $var_lastinvoice | grep settle_date | cut -d '"' -f 4)
fi

settledelta=`expr $settledate - $oldsettledate`

echo "$(date)"
#echo "timestamp: $(date '+%s')"
echo "settledate: $settledate"
echo "settledelta: $settledelta"

if [ $rhash != $oldrhash ] && [ $sat -eq $var_satoshi ]
then
   if [ $settledelta -gt 60 ]
   then
      echo "!! settledelta -gt 60"
      account=$((account+1))
      checktime=$current
   fi
   account=$((account+5))
fi

current=$(date '+%s')
delta=`expr $current - $checktime`

echo "Delta is: $delta"
if [ $delta -ge $var_seconds ]
then
   [ $account -le 0 ] || account=$((account-1))
   checktime=$current
fi

echo "Account is: $account"
if [ "$account" -ge 1 ]
then
   echo Driving!
   python3 power-on.py
   python3 game-on.py && python3 game-off.py &
else
   echo Stop!
   python3 power-off.py
fi
echo ""

#sleep 1

done
