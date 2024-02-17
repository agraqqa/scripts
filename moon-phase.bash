#!/bin/bash

# Function to calculate the current moon phase
function moonphase(){
    # Approximate lunar period (29.53 days) in seconds
    local lunar_period=2551443
    local now
    now=$(date -u +"%s")
    local newmoon=592500
    local phase=$(((now - newmoon) % lunar_period))
    local phase_number=$((((phase / 86400) + 1)*100000))
    if   [ $phase_number -lt 184566 ];   then emoji="🌑"
    elif [ $phase_number -lt 553699 ];   then emoji="🌒"
    elif [ $phase_number -lt 922831 ];   then emoji="🌓"
    elif [ $phase_number -lt 1291963 ];  then emoji="🌔"
    elif [ $phase_number -lt 1661096 ];  then emoji="🌕"
    elif [ $phase_number -lt 2030228 ];  then emoji="🌖"
    elif [ $phase_number -lt 2399361 ];  then emoji="🌗"
    elif [ $phase_number -lt 2768493 ];  then emoji="🌘"
    else
        emoji="🌑"             
    fi

    echo "$emoji"
}

moonphase