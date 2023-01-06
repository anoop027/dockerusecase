#!/bin/bash
function prop {
    grep "${1}" /home/ubuntu/mem.properties|cut -d'=' -f2
}

cpulimit=$(prop 'mem.cpu.load')
memlimit=$(prop 'mem.ram.usage')
diskspace=$(prop 'mem.disk.consumed')
EMAIL=$(prop 'mem.user.email')

printf "Memory\t\tDisk\t\tCPU\n" > /tmp/mem
end=$((SECONDS+1200))
m=5
while [ $SECONDS -lt $end ];
do
        MEMORY=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
        DISK=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}')
        CPU=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}')
        echo "$MEMORY$DISK$CPU" >> /tmp/mem
        cpuuse=$(cat /proc/loadavg | awk '{print $3}'|cut -f 1 -d ".")
        memuse=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }' | cut -f 1 -d ".")
        diskuse=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}' | cut -f 1 -d "%")
        if [ $cpuuse -gt $cpulimit ] || [ $memuse -gt $memlimit ] || [ $diskuse -gt $diskspace ];
        then
           echo CPU- $CPU, MEMORY- $MEMORY, DISKSPACE- $DISK at $(date +"%T") ---values logged to file /tmp/mem
           SUBJECT="ATTENTION: Memory/disk space/cpu is high on $(hostname) at $(date)"
           msg=$(echo Memory used is $MEMORY, CPU load is $CPU and Disk consumed $DISK. One of the metrics has breached threshold. Please take necessary action)
           mail -s "$SUBJECT" $EMAIL <<< "$msg"
        else
           echo all metrics are under threshold
        fi
sleep 5
done

