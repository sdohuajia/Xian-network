#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Xian.sh"

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "================================================================"
        echo "节点社区 Telegram 群组: https://t.me/niuwuriji"
        echo "节点社区 Telegram 频道: https://t.me/niuwuriji"
        echo "节点社区 Discord 社群: https://discord.gg/GbMV5EcNWF"
        echo "退出脚本，请按键盘 ctrl+c 退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装节点"
        echo "2. 启动节点"
        echo "3. 查看日志"
        echo "4. 停止节点"
        echo "5. 退出脚本"
        
        read -p "请输入选择 (1/2/3/4/5): " choice

        case $choice in
            1)
                install_node
                ;;
            2)
                start_node
                ;;
            3)
                view_logs
                ;;
            4)
                stop_node
                ;;
            5)
                echo "退出脚本。"
                exit 0
                ;;
            *)
                echo "无效选择，请输入 1、2、3、4 或 5。"
                ;;
        esac
    done
}

# 安装节点函数
function install_node() {
    # 更新系统软件包
    sudo apt update

    # 安装 make 工具
    sudo apt install -y make

    # 检查 Docker 是否安装
    if ! command -v docker &> /dev/null
    then
        # 下载并安装 Docker
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        
        # 下载并安装 Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        
        # 删除安装脚本
        rm get-docker.sh
        
        echo "Docker 和 Docker Compose 安装完成！"
    else
        echo "Docker 已安装。"
    fi

    # 克隆 xian-stack 仓库
    git clone https://github.com/xian-network/xian-stack.git

    # 进入 xian-stack 目录
    cd xian-stack || { echo "无法进入 xian-stack 目录"; exit 1; }

    # 运行设置命令
    make setup

    # 选择节点类型
    echo "请选择节点类型："
    echo "1. Validator 节点"
    echo "2. Blockchain Data Service 节点"
    read -p "请输入选择 (1/2): " node_choice

    if [ "$node_choice" -eq 1 ]; then
        # Validator 节点
        echo "正在构建 Validator 节点..."
        make core-build
        make core-up
        make init
        read -p "请输入您的 moniker: " moniker
        read -p "请输入您的私钥: " priv_key
        
        make configure CONFIGURE_ARGS="--moniker $moniker --genesis-file-name genesis-rcnet.json --validator-privkey $priv_key --seed-node 188.68.33.32 --copy-genesis"
        echo "Validator 节点已设置完成！"

    elif [ "$node_choice" -eq 2 ]; then
        # Blockchain Data Service 节点
        echo "正在构建 Blockchain Data Service 节点..."
        make core-bds-build
        make core-bds-up
        make init
        read -p "请输入您的 moniker: " moniker
        read -p "请输入您的私钥: " priv_key
        
        make configure CONFIGURE_ARGS="--moniker $moniker --genesis-file-name genesis-rcnet.json --validator-privkey $priv_key --seed-node 188.68.33.32 --copy-genesis --service-node"
        echo "Blockchain Data Service 节点已设置完成！"

    else
        echo "无效选择，请输入 1 或 2。"
    fi
}

# 启动节点函数
function start_node() {
    echo "请选择要启动的节点类型："
    echo "1. Validator 节点"
    echo "2. Blockchain Data Service 节点"
    read -p "请输入选择 (1/2): " node_choice

    if [ "$node_choice" -eq 1 ]; then
        # 启动 Validator 节点
        echo "正在启动 Validator 节点..."
        make core-shell
        make up
        echo "Validator 节点已启动！"

    elif [ "$node_choice" -eq 2 ]; then
        # 启动 Blockchain Data Service 节点
        echo "正在启动 Blockchain Data Service 节点..."
        make core-bds-shell
        make up-bds
        echo "Blockchain Data Service 节点已启动！"

    else
        echo "无效选择，请输入 1 或 2。"
    fi
}

# 查看日志函数
function view_logs() {
    echo "请选择要查看日志的节点类型："
    echo "1. Validator 节点"
    echo "2. Blockchain Data Service 节点"
    read -p "请输入选择 (1/2): " node_choice

    if [ "$node_choice" -eq 1 ]; then
        # 查看 Validator 节点日志
        echo "正在查看 Validator 节点日志..."
        make core-shell
        cd xian-core || { echo "无法进入 xian-core 目录"; exit 1; }
        pm2 logs
    elif [ "$node_choice" -eq 2 ]; then
        # 查看 Blockchain Data Service 节点日志
        echo "正在查看 Blockchain Data Service 节点日志..."
        make core-bds-shell
        cd xian-bds || { echo "无法进入 xian-bds 目录"; exit 1; }
        pm2 logs
    else
        echo "无效选择，请输入 1 或 2。"
    fi
}

# 停止节点函数
function stop_node() {
    echo "正在停止节点..."
    make down
    echo "节点已停止！"
}

# 运行主菜单
main_menu
