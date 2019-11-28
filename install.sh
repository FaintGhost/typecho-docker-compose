#!/bin/sh

SetDomain(){
    read -p "请输入你要作为博客的域名: " domain
    sed -i "s/yourdomain.com/$domain/g" /root/app/typechohttp.conf
    sed -i "s/yourdomain.com/$domain/g" /root/app/typechohttps.conf
    mv typechohttp.conf typecho.conf
    echo "将域名设定为$domain"
}

SetDB(){
    read -p "请输入数据库名: " dbname
    read -p "请输入数据库ROOT密码: " dbrootpw
    read -p "请输入数据库用户名: " dbun
    read -p "请输入数据库密码: " dbpw
    sed -i "s/MYSQL_DATABASE=typecho/MYSQL_DATABASE=$dbname/g" /root/app/mysql.env
    sed -i "s/myrootpassword/$dbpw/g" /root/app/mysql.env
    sed -i "s/MYSQL_USER=typecho/MYSQL_USER=$dbun/g" /root/app/mysql.env
    sed -i "s/mypassword/$dbpw/g" /root/app/mysql.env
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
                sed -i "s/'user' => 'typecho'/'user' => '$dbun'/g" /root/app/config.inc.php
                sed -i "s/'password' => 'mypassword'/'password' => '$dbpw'/g" /root/app/config.inc.php
                sed -i "s/'database' => 'typecho'/'database' => '$dbname'/g" /root/app/config.inc.php
                mv /root/app/config.inc.php /root/app/typecho
                break
            ;;
            [nN][oO]|[nN])
                echo "请完成基本配置！"
            ;;
            *)
                echo "请完成基本配置！"
            ;;
        esac
    done
}

EnableSSL(){
    while true
    do
        read -r -p "是否要开启SSL? [y/n]" input
        
        case $input in
            [yY][eE][sS]|[yY])
                mv typecho.conf typechohttp.conf
                mv typechohttps.conf typecho.conf
                sed -i "s/#define('__TYPECHO_SECURE__',true);/define('__TYPECHO_SECURE__',true);/g" /root/app/typecho/config.inc.php
                sed -i 's#$this->commentUrl()#echo str_replace("http","https",\$this->commentUrl());#g' /root/app/typecho/usr/themes/default/comments.php
                chmod +x /root/app/acme.sh/acme.sh
                /root/app/acme.sh/acme.sh --issue -d $domain -w /root/app/typecho --force
                mv /root/.acme.sh/$domain/fullchain.cer /root/app/typecho
                mv /root/.acme.sh/$domain/$domain.key /root/app/typecho
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

echo "开始安装"
SetDomain
echo "域名配置完成"
echo "----------------------------------------"
echo "开始配置数据库"
SetDB
echo "数据库配置完成"
echo "----------------------------------------"
echo "开始安装"
cd /root/app
docker-compose up -d
echo "安装完成，请打开http://$domain进行基本配置"
echo "----------------------------------------"
Config
echo "请回到网页完成后续配置"
echo "----------------------------------------"
EnableSSL