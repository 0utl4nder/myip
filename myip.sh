#!/bin/bash

RED='\033[0;31m'
ALT_RED='\033[1;31m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
ALT_BLUE='\033[1;34m'
PURPLE='\033[0;35m'
NC='\033[0m' #No color

ip=$(curl -s https://checkip.amazonaws.com)
err=()
commas=0

function Help() {
  echo -e "${CYAN} Script version 1.2 | by @0utl4nder | https://github.com/0utl4nder/myip ${NC}"
  echo -e "${RED}This version is not able to run -l and -s at once. eg.'$0 -s wlan0,eth0 -l 1.1.1.1,9.9.9.9'${NC}"
  echo -e "${ALT_BLUE}Usage: $0 [option] [value]${NC}"
  echo -e "${PURPLE}+ Example:  ${NC}${CYAN}'$0 -l 8.8.8.8,1.1.1.1'  '$0 -s eth0,wlo1'${NC}"
  echo -e "${ALT_BLUE}Options:${NC}"
  echo -e "${PURPLE}+ General Use${NC}"
  echo -e "${RED}[-]${NC}${YELLOW}Local Data Recolection Mode${NC}\t| ${CYAN}-l [IP/check]${NC}"
  echo -e "${ALT_BLUE}[i]${NC}${YELLOW}Local Data refers to Country, City, Postal code and ISP from a given IP, or a detected IP${NC}"
  echo -e "${RED}[-]${NC}${YELLOW}Self Data Recolection Mode${NC}\t| ${CYAN}-s [INTERFACE/check]${NC}"
  echo -e "${ALT_BLUE}[i]${NC}${YELLOW}Self Data refers to Local IP address, Broadcast and MAC address from a given interface, or the active interfaces detected${NC}"
  echo -e "${RED}[-]${NC}${YELLOW}Everything${NC}\t\t\t| ${CYAN}-a [check]${NC}"
  echo -e "${ALT_BLUE}[i]${NC}${YELLOW}Does everything${NC}"
  echo -e "${RED}[-]${NC}${YELLOW}Help Panel${NC}\t\t\t| ${CYAN}-h${NC}"
}

function Dependencies() {
  local dependencies=("jq" "curl")

  for dependency in "${dependencies[@]}"; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
      echo -e "${RED}[! - Error] $dependency isn't installed.${NC}"
      exit 1
    fi
  done
}

function Self_Data() {
  function identifier() {
    echo -e "${BLUE}-[i]${Nc} ${ALT_BLUE}Self Data detected${NC}"
    local interfaces=()
    #IFS (internal field separator)
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

  if [[ $1 == 'check' ]]; then
    identifier
  elif [[ $commas -eq 0 ]]; then
    if ip addr show dev $1 >/dev/null 2>&1; then
      echo -e "${BLUE}-[i]${Nc} ${ALT_BLUE}Self Data from given interface $1${NC}"
      local ip=$(ip addr show dev $1 | awk '/inet / {print $2}')
      local brd=$(ip addr show dev $1 | awk '/inet / {print $4}')
      local mac_addr=$(ip link show dev $1 | awk '/link\/ether/ {print $2}')
      echo -e "${PURPLE}Interface:${NC} ${YELLOW}$1${NC} | ${PURPLE}IP:${NC} ${YELLOW}$ip${NC} - ${PURPLE}Broadcast:${NC} ${YELLOW}$brd${NC} | ${PURPLE}Mac addr:${NC} ${YELLOW}$mac_addr${NC}"
    fi
  elif [[ $commas -gt 0 ]]; then
    echo -e "${BLUE}-[i]${Nc} ${ALT_BLUE}Self Data from given interfaces ${multipleS[@]}${NC}"
    for ((z = 0; z <= $((${#multipleS[@]} - 1)); z++)); do
      if ip addr show dev ${multipleS[$z]} >/dev/null 2>&1; then
        local ip=$(ip addr show dev ${multipleS[$z]} | awk '/inet / {print $2}')
        local brd=$(ip addr show dev ${multipleS[$z]} | awk '/inet / {print $4}')
        local mac_addr=$(ip link show dev ${multipleS[$z]} | awk '/link\/ether/ {print $2}')
        echo -e "${PURPLE}Interface:${NC} ${YELLOW}${multipleS[$z]}${NC} | ${PURPLE}IP:${NC} ${YELLOW}$ip${NC} - ${PURPLE}Broadcast:${NC} ${YELLOW}$brd${NC} | ${PURPLE}Mac addr:${NC} ${YELLOW}$mac_addr${NC}"
      else
        err+=($z)
      fi
    done
    if [[ ${#err[@]} -gt 0 ]]; then
      for ((a = 0; a <= $((${#err[@]} - 1)); a++)); do
        echo -e "${RED}[! - Error]${NC} ${ALT_RED}${multipleS[${err[$a]}]}${NC} ${RED}interface is not active, or is invalid.${NC}"
      done
      exit 1
    fi
  else
    echo -e "${RED}[! - Error]${NC} ${ALT_RED}$1${NC} ${RED}interface is not active, or is invalid.${NC}"
    exit 1
  fi
}

function Local_Data() {
  Dependencies
  if [[ $1 == 'check' ]]; then
    echo -e "${BLUE}-[i]${NC} ${ALT_BLUE}Public Data from detected IP $ip ${NC}"
    local response=$(curl -s "http://ip-api.com/json/$ip")
    local country=$(echo "$response" | jq -r '.country')
    local city=$(echo "$response" | jq -r '.city')
    local zip=$(echo "$response" | jq -r '.zip')
    local isp=$(echo "$response" | jq -r '.isp')
    echo -e "${PURPLE}Local IP:${NC} ${YELLOW}$ip${NC} | ${PURPLE}Location:${NC} ${YELLOW}$country - $city - $zip${NC} | ${PURPLE}ISP:${NC} ${YELLOW}$isp${NC}"
  elif [[ $commas -eq 0 ]]; then
    local response=$(curl -s "http://ip-api.com/json/$1")
    local status=$(echo "$response" | jq -r '.status')
    case $status in
    fail)
      echo -e "${RED}[! - Error]${NC} ${ALT_RED}$1${NC} ${RED}IP is unreachable, or is invalid.${NC}"
      exit 1
      ;;
    success)
      echo -e "${BLUE}-[i]${NC} ${ALT_BLUE}Public Data from given IP $1 ${NC}"
      local country=$(echo "$response" | jq -r '.country')
      local city=$(echo "$response" | jq -r '.city')
      local zip=$(echo "$response" | jq -r '.zip')
      local isp=$(echo "$response" | jq -r '.isp')
      echo -e "${PURPLE}Local IP:${NC} ${YELLOW}$1${NC} | ${PURPLE}Location:${NC} ${YELLOW}$country - $city - $zip${NC} | ${PURPLE}ISP:${NC} ${YELLOW}$isp${NC}"
      ;;
    esac
  elif [[ $commas -gt 0 ]]; then

    echo -e "${BLUE}-[i]${Nc} ${ALT_BLUE}Self Data from given IP's ${multipleL[@]}${NC}"
    for ((z = 0; z <= $((${#multipleL[@]} - 1)); z++)); do
      local response=$(curl -s "http://ip-api.com/json/${multipleL[$z]}")
      local status=$(echo "$response" | jq -r '.status')
      case $status in
      fail)
        err+=($z)
        ;;
      success)
        local country=$(echo "$response" | jq -r '.country')
        local city=$(echo "$response" | jq -r '.city')
        local zip=$(echo "$response" | jq -r '.zip')
        local isp=$(echo "$response" | jq -r '.isp')
        echo -e "${PURPLE}Local IP:${NC} ${YELLOW}${multipleL[$z]}${NC} | ${PURPLE}Location:${NC} ${YELLOW}$country - $city - $zip${NC} | ${PURPLE}ISP:${NC} ${YELLOW}$isp${NC}"
        ;;
      esac
    done
    if [[ ${#err[@]} -gt 0 ]]; then
      for ((a = 0; a < $((${#err[@]})); a++)); do
        echo -e "${RED}[! - Error]${NC} ${ALT_RED}${multipleL[${err[$a]}]}${NC} ${RED}IP is unreachable, or is invalid.${NC}"
      done
      exit 1
    fi
  fi
}

option=0
while getopts "s:l:a:h:" arg; do
  case $arg in
  s)
    argument=$OPTARG
    let option+=1
    ;;
  l)
    argument=$OPTARG
    let option+=2
    ;;
  a)
    argument=$OPTARG
    let option+=3
    ;;
  h) Help ;;
  esac
done

if [ $option -eq 0 ]; then
  Help
  exit 1
fi

if [[ $option -eq 1 ]]; then
  if [[ "$(echo $argument | grep ',')" ]]; then
    for ((x = 0; x < ${#argument}; x++)); do
      if [[ ${argument:$x:1} == ',' ]]; then
        commas+=1
      fi
    done
    IFS=',' read -r -a multipleS <<<"$argument"
  fi
  Self_Data $argument
fi

if [[ $option -eq 2 ]]; then
  if [[ "$(echo $argument | grep ',')" ]]; then
    for ((x = 0; x < ${#argument}; x++)); do
      if [[ ${argument:$x:1} == ',' ]]; then
        commas+=1
      fi
    done
    IFS=',' read -r -a multipleL <<<"$argument"
  fi
  Local_Data $argument
fi

if [[ $option -eq 3 ]]; then
  if [[ $argument == "check" ]]; then
    Self_Data $argument
    Local_Data $argument
  else
    Help
    exit 1
  fi
fi
