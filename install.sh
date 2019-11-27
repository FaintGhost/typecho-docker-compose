#!/bin/sh
IP="curl http://members.3322.org/dyndns/getip"

SetDomain(){
    read -p "请输入你要作为博客的域名: " domain
    sed -i "s/yourdomain.com/$domain/g" /root/app/typecho.conf
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
    read -p "是否提示无法创建config.inc.php文件?" yn

    if $yn="y"
    then
        sed -i "s/'user' => 'typecho'/'user' => '$dbun'/g" /root/app/config.inc.php
        sed -i "s/'password' => 'mypassword'/'password' => '$dbpw'/g" /root/app/config.inc.php
        sed -i "s/'database' => 'typecho'/'database' => '$dbname'/g" /root/app/config.inc.php
        mv /root/app/config.inc.php /root/app/typecho
    else
        echo "请完成基本配置！"
        Config
}

#EnableSSL(){
#
#}

echo "开始安装"
SetDomain
echo "域名配置完成"
echo "-------------------------------------"
echo "开始配置数据库"
SetDB
echo "数据库配置完成"
echo "-------------------------------------"
echo "开始安装"
cd /root/app
docker-compose up -d
echo "安装完成，请打开http://$domain进行基本配置"
echo "----------------------------------------"
Config