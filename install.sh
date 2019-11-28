#!/bin/sh

INSTALL_PATH=`pwd`

SetDomain(){
    read -p "请输入你要作为博客的域名: " domain
    sed -i "s/yourdomain.com/$domain/g" $INSTALL_PATH/typechohttp.conf
    sed -i "s/yourdomain.com/$domain/g" $INSTALL_PATH/typechohttps.conf
    mv typechohttp.conf typecho.conf
    echo "将域名设定为$domain"
}

SetDB(){
    read -p "请输入数据库名: " dbname
    read -p "请输入数据库ROOT密码: " dbrootpw
    read -p "请输入数据库用户名: " dbun
    read -p "请输入数据库密码: " dbpw
    sed -i "s/MYSQL_DATABASE=typecho/MYSQL_DATABASE=$dbname/g" $INSTALL_PATH/mysql.env
    sed -i "s/myrootpassword/$dbrootpw/g" $INSTALL_PATH/mysql.env
    sed -i "s/MYSQL_USER=typecho/MYSQL_USER=$dbun/g" $INSTALL_PATH/mysql.env
    sed -i "s/mypassword/$dbpw/g" $INSTALL_PATH/mysql.env
}

GetIPAddress(){
    getIpAddress=""
    getIpAddress=$(curl -sS --connect-timeout 10 -m 60 http://members.3322.org/dyndns/getip)
}

Config(){
    while true
    do
        read -r -p "是否提示无法创建config.inc.php文件? [y/n] " input
        
        case $input in
            [yY][eE][sS]|[yY])
                sed -i "s/'user' => 'typecho'/'user' => '$dbun'/g" $INSTALL_PATH/config.inc.php
                sed -i "s/'password' => 'mypassword'/'password' => '$dbpw'/g" $INSTALL_PATH/config.inc.php
                sed -i "s/'database' => 'typecho'/'database' => '$dbname'/g" $INSTALL_PATH/config.inc.php
                mv $INSTALL_PATH/config.inc.php $INSTALL_PATH/typecho
                echo "已创建config.inc.php文件"
                break
            ;;
            [nN][oO]|[nN])
                echo "请完成基本配置"
            ;;
            *)
                echo "请完成基本配置"
            ;;
        esac
    done
}

EnableSSL(){
    while true
    do
        read -r -p "是否要开启全站SSL? [y/n]" input
        
        case $input in
            [yY][eE][sS]|[yY])
                mv typecho.conf typechohttp.conf
                mv typechohttps.conf typecho.conf
                sed -i "s/#define('__TYPECHO_SECURE__',true);/define('__TYPECHO_SECURE__',true);/g" $INSTALL_PATH/typecho/config.inc.php
                sed -i 's#$this->commentUrl()#echo str_replace("http","https",\$this->commentUrl());#g' $INSTALL_PATH/typecho/usr/themes/default/comments.php
                echo "使用acme.sh申请Let's Encrypt证书"
                chmod +x $INSTALL_PATH/acme.sh/acme.sh
                $INSTALL_PATH/acme.sh/acme.sh --issue -d $domain -w $INSTALL_PATH/typecho --force
                echo "证书申请成功"
                mv /root/.acme.sh/$domain/fullchain.cer $INSTALL_PATH/ssl
                mv /root/.acme.sh/$domain/$domain.key $INSTALL_PATH/ssl
                docker-compose restart nginx
                echo "所有配置已完成"
                echo "请使用https://$domain访问您的博客"
                break
            ;;
            [nN][oO]|[nN])
                echo "所有配置已完成"
                break
            ;;
            *)
                echo "所有配置已完成"
                break
            ;;
        esac
    done
}

Setup(){
    echo "开始安装"
    SetDomain
    echo "域名配置完成"
    echo "----------------------------------------"
    echo "开始配置数据库"
    SetDB
    echo "数据库配置完成"
    echo "----------------------------------------"
    echo "开始安装"
    cd $INSTALL_PATH
    docker-compose up -d
    echo "安装完成，请打开http://$domain进行基本配置"
    echo "----------------------------------------"
    Config
    echo "请回到网页完成后续配置"
    echo "----------------------------------------"
    EnableSSL
}

Setup