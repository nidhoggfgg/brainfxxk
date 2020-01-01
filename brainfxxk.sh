#!/bin/bash
# 安全编程，千万不要开……
#set -o nounset
#set -o errexit
# 初始化必要的变量
# stack为数据栈，stack_size为栈大小，for是为了将所有栈设置为0
# offset即当前执行栈指针偏移量，pointer即数据栈指针
# code为代码string
stack=( 0 )
stack_size=301
for (( i = 0; i < stack_size; i+=1)); do
    stack[$i]=0
done
offset=0
pointer=150
code=
s=0
s_=1
s__=2
s___=3
s____=4
s_____=5
s______=6
s_______=7
s________=8
# 去到[处
goto_right() {
    local count=0
    until [[ count -lt 0 ]]; do
        ((offset++))
        # 是否有[
        if [[ offset -ge ${#code} ]]; then
            echo "emmm……你貌似少写了个'['吧"
            exit 1
        fi
        # 处理多层嵌套
        layer="${code:$offset:1}"
        if [[ "$layer" == '[' ]]; then
            ((count++))
        elif [[ "$layer" == ']' ]]; then
            ((count--))
        fi
    done
}

# 寻找]
goto_left() {
    local count=0
    until [[ count -lt 0 ]]; do
        ((offset--))
        # 寻找]
        if [[ offset -lt 0 ]]; then
            echo "你貌似少写了个']'吧"
            exit 1
        fi
        # 处理多层嵌套
        layer="${code:$offset:1}"
        if [[ "$layer" == '[' ]]; then
            ((count--))
        elif [[ "$layer" == ']' ]]; then
            ((count++))
        fi
    done
}

myput() {
    # 打印char类型
    echo $1 | awk '{printf("%c", $1)}'
}

myhelp() {
    echo "一个brainfuck解释器"
    echo "-f <文件>解释文件"
    echo "-s <字符串>解释字符串"
    echo "-c <导入config文件>"
}
while getopts ":f:s:c:h" argv
do
        case $argv in
             f)
                 code=$(cat $OPTARG) ;;
             s)
                 code=$OPTARG ;;
             c)
                 source $OPTARG ;;
             h)
                 myhelp ;;
         esac
done
code=${code//$s/+}
code=${code//$s_/-}
code=${code//$s__/>}
code=${code//$s___/<}
code=${code//$s____/.}
code=${code//$s_____/,}
code=${code//$s______/[}
code=${code//$s_______/]}
code=${code//$s________/~}
# 开始循环
while [[ $offset -le ${#code} ]]; do
    now_code="${code:$offset:1}"
    case "$now_code" in
        '+')
            (( stack[$pointer]++ ));;
        '-')
            (( stack[$pointer]-- ));;
        '>')
            (( pointer++ ))

            if [[ pointer -ge $stack_size ]]; then
                echo "栈爆了,请自行配置config来增加栈容量和改变初始指针位置.\n ps.推荐优化代码"
                exit 1
            fi
            ;;

        '<')
            (( pointer-- ))

            if [[ pointer -lt 0 ]]; then
                echo "栈爆了,请自行配置config来增加栈容量和改变初始指针位置.\n ps.推荐优化代码"
                exit 1
            fi
            ;;
        '.')
            myput "${stack[$pointer]}";;

        ',')
            read -n 1 input
            stack[$pointer]=$(printf '%d' "'$input")
            ;;

        '[')
            if [[ ${stack[$pointer]} -eq 0 ]]; then
                goto_right
            fi
            ;;

        ']')
            if [[ ${stack[$pointer]} -ne 0 ]]; then
                goto_left
            fi
            ;;
        '~')
            sleep 0.1 ;;
    esac
    ((offset++))
done
