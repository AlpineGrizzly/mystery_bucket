#!/bin/bash
# ng2pcap.sh 
# Crude script for creating pcaps out of ethernet encapsulated packets in pcapng files
# Author AlpineGrizzly 

set -e

PCAPNG_DIR="pcapng_files"
PCAP_DIR="pcap_files"

# Do we have an argument
if [ -z "$1" ]; then
    echo "Usage ./ng2pcap.sh <pcapng_file>"
    exit
fi

# Check if files exists    
if [ -f "$1" ]; then
    PCAPNG_FILE="$1"
else
    echo "Usage ./ng2pcap.sh <pcapng_file>"
    exit
fi

if [ -d $PCAPNG_DIR ]; then 
    rm -rf $PCAPNG_DIR
fi

if [ -d $PCAP_DIR ]; then 
    rm -rf $PCAP_DIR
fi

# Get number of interfaces 
INTERFACES=$(($(capinfos $PCAPNG_FILE | grep Interface | wc -l | awk '{print $1}')))

# Create separate pcapng files for each + creating respective pcaps after filtering on encap type
mkdir $PCAPNG_DIR
mkdir $PCAP_DIR
for (( FACE=0; FACE<$INTERFACES; FACE++ )); do
    echo "Writing $FACE.pcap..."
    tshark -r $PCAPNG_FILE -w $PCAPNG_DIR/$FACE.pcapng "frame.interface_id == $FACE"
    # Convert pcapng files to pcap files
    editcap -F pcap -T ether $PCAPNG_DIR/$FACE.pcapng $PCAP_DIR/$FACE.pcap
done 
