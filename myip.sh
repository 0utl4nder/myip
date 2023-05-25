#!/bin/bash
function myip() {

local RED='\033[0;31m'
local YELLOW='\033[0;33m'
local BLUE='\033[0;34m'
local ALT_BLUE='\033[1;34m'
local PURPLE='\033[0;35m'
local NC='\033[0m' # No color

  function checkDependencies() {
    dependencies=("jq" "curl")
    
    for dependency in "${dependencies[@]}"; do 
      if ! command -v "$dependency" > /dev/null 2>&1; then
        echo -e "${RED}[! - Error] $dependency isn't installed.${NC}"
        exit 1
      fi 
    done
  }

  function localData(){
    echo -e "${BLUE}-[i]${NC} ${ALT_BLUE}Public data${NC}"
    echo " "
    local ip=$(curl -s https://checkip.amazonaws.com)
    local response=$(curl -s "http://ip-api.com/json/$ip")
 
    local country=$(echo "$response" | jq -r '.country')
    local city=$(echo "$response" | jq -r '.city')
    local zip=$(echo "$response" | jq -r '.zip')
    local isp=$(echo "$response" | jq -r '.isp')

    echo -e "${PURPLE}Local IP:${NC} ${YELLOW}$ip${NC} | ${PURPLE}Location:${NC} ${YELLOW}$country - $city - $zip${NC} | ${PURPLE}ISP:${NC} ${YELLOW}$isp${NC}"
  }

function privateData() {
    echo -e "${BLUE}-[i]${Nc} ${ALT_BLUE}Private data${NC}"
    echo " "

    function identify() {

        local interfaces=()
        #IFS (internal  field separator)
        while IFS= read -r line; do
            if [[ $line =~ ^[0-9]+:\ .+state\ UP ]]; then
                interfaces+=("$(echo "$line" | awk '{print $2}' | sed 's/://')")
            fi
        done < <(ip a) # Takes `ip a` output, as input for while

        for iface in "${interfaces[@]}"; do
            local ip=$(ip addr show dev $iface | awk '/inet / {print $2}')
            local brd=$(ip addr show dev $iface | awk '/inet / {print $4}')
            local mac_addr=$(ip link show dev $iface | awk '/link\/ether/ {print $2}')

            echo -e "${PURPLE}Interface:${NC} ${YELLOW}$iface${NC} | ${PURPLE}IP:${NC} ${YELLOW}$ip${NC} - ${PURPLE}Broadcast:${NC} ${YELLOW}$brd${NC} | ${PURPLE}Mac addr:${NC} ${YELLOW}$mac_addr${NC}"
        done
    }

    identify
}


  checkDependencies
  privateData
  echo " "
  localData
}

myip
