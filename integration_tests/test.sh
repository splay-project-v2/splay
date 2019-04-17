RTT=$(printf "FINAL RTT : 1.26358882 dfvsdsdsdsssss\nFINAL RTT : 1.26358882 dfvsdsds" | grep -oP -m 1 "FINAL RTT : \K[0-9]+\.[0-9]*")
echo "RTT = ${RTT} sec"

if [[ $(bc -l <<< "${RTT} > 1.2499") -eq 0 ]]; then
    echo "RTT Can't be smaller than 1.2499, topo_socket doesn't work ?"
fi