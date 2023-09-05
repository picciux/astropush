#! /bin/sh

prio=warn

[ "$1" != "" ] && prio=$1

for m in os kstars alignment capture focus guide mount scheduler unknown; do
  astropush $m "Testing $m module notification" $prio
done

