#! /bin/bash
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
RESET='\033[0m'
function printTable()
{
	table=""
    export delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

	local -r numberOfLines="$(wc -l <<< "${data}")"

	for ((i =1; i <= "${numberOfLines}"; i = i + 1))
	do
		line="$(sed "${i}q;d" <<< "${data}")"
		numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"
		splitLine ${numberOfColumns}
		setRow ${line}
	done
splitLine ${numberOfColumns}
setTable "${table}"
}

function removeEmptyLines()
{
    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

#======================================================
# 设置行，可以是表头，也可以是表格内容。
# 如果是表格内容，“—”表示空值
#======================================================
function setRow()
{
    value=$*
	table=${table}"|${value//${delimiter}/#|}#|\n"
}

#======================================================
# 行分隔线
# 入参：表格的列数。如表格有9列，则入参为9
#======================================================
function splitLine()
{
    local num=`expr $1 + 1`
    table=${table}"`seq -s '+#' $num | sed 's/[0-9]//g'`\n"
}

#======================================================
# 绘制表格
#======================================================
function setTable()
{
    echo -e ${1}|column -s "#" -t|awk '{if($0 ~ /^+/){gsub(" ","-",$0);print $0}else{print $0}}'
}



#======================================================
# Main
#======================================================
echo -e "${YELLOW}Please wait for check...${RESET}"
printTable ':' "$(
export LANG=en_US.UTF-8
echo -e "Hostname: $(hostname)"
echo -e "Time Zone: $(timedatectl |grep -E "zone" |column -t  -s:|sed 's/^[ \t]*//'|awk '{print $3}')"
yum makecache >/dev/null 2>&1; if [ $? -eq 0 ];then echo -e "Yum Repo: OK"; else echo -e "Yum repo: Failed"; fi

if command -v lsb_release >/dev/null 2>&1; then
    echo -e "Release: $(lsb_release -as)"
else
    echo -e "Release: $(cat /etc/os-release |grep PRETTY_NAME|cut -d= -f2| tr -d '"')" 
fi

echo -e "Kernel: `uname -srm`"
echo -e "Memory: $(lsmem |grep "online memory:"|awk '{print $4}')"
echo -e "CPU(s): $(lscpu |grep -E "^CPU\(s\):"|awk '{print $2}')"
)"
echo -e "${MAGENTA}======================Network Interface============================${RESET}"

printTable ':' "$(echo "Network Interface:IP" && ip addr | awk '/inet /{sub(/\/.*$/,"",$2);print $NF":"$2}' | tr ' ' ':')"

echo -e "${MAGENTA}========================Disk:Device===============================${RESET}"

printTable ':' "$(
echo -e "Disk: Size"
lsblk --nodeps --output NAME,SIZE|sed '1d' |sed 's/\s\+/: /1'
)"
echo -e "${MAGENTA}===========================Mount Point============================${RESET}"
printTable ' ' "$(df -h|sed 's/Mounted on/Mounted_on/g')"


# $ cat data-2.txt
# HEADER 1,HEADER 2,HEADER 3
# data 1,data 2,data 3

# $ printTable ',' "$(cat data-2.txt)"
# +-----------+-----------+-----------+
# | HEADER 1  | HEADER 2  | HEADER 3  |
# +-----------+-----------+-----------+
# | data 1    | data 2    | data 3    |
# +-----------+-----------+-----------+




# # cat test 
# +#+#+#+#+#+#+#+#+#+#+#\n|ip#|hostname#|os_type#|memory#|core#|LANG#|\n+#+#+#+#+#+#+#+#+#+#+#\n|127777#|demodemo#|centos#|111#|12#|EN#|\n+#+#+#+#+#+#+#+#+#+#+#\n
# echo -e `cat test` |column -s "#" -t|awk '{if($0 ~ /^+/){gsub(" ","-",$0);print $0}else{print $0}}'

# table=""
# # splitLine 列数
# splitLine 1
# setRow "ip" "hostname" "os_type" "memory" "core" "LANG"
# splitLine 3
# setRow "127777" "demod22222222222222222222222222 22222222222222222222222222emo" "centos" " 2" "2 " "EN"
# splitLine 7

# setTable ${table}
# echo -e ${table} | column -s "#" -t|awk '{if($0 ~ /^+/){gsub(" ","-",$0);print $0}else{print $0}}'

##########################################################################

# printTable ':' "$(echo "Network Interface:IP" && ip addr | awk '/inet /{sub(/\/.*$/,"",$2);print $NF":"$2}' | tr ' ' ':')"

# printTable ':' "$(echo -e "${MAGENTA}Network Interface:IP${RESET}" && ip addr | awk '/inet /{sub(/\/.*$/,"",$2);print $NF":"$2}' | tr ' ' ':')"
# echo ${table}
# echo -e ${table} | column -s "#" -t|awk '{if($0 ~ /^+/){gsub(" ","-",$0);print $0}else{print $0}}'
# head name1+cloer