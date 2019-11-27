#!/bin/sh


SetDomain(){
    read -p "请输入你要作为博客的域名: " domain
    sed -i "s/yourdomain.com/$domain/g" /root/app/typecho.conf
    echo "将域名设定为$domain"
}

SetDB(){
    read -p "请输入数据库ROOT密码: " dbrootpw
    read -p "请输入数据库用户名: " dbun
    read -p "请输入数据库密码: " dbpw
    sed -i "s/myrootpassword/$dbpw/g" /root/app/mysql.env
    sed -i "s/typecho/$dbun/g" /root/app/mysql.env
    sed -i "s/mypassword/$dbpw/g" /root/app/mysql.envs
    mv /root/app/config.inc.php /root/app/typecho
}

EnableSSL(){
    
}

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