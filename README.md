踩了很多坑的使用docker搭建typecho博客

#### 安装

克隆仓库

```bash
git clone --recursive https://github.com/FaintGhost/typecho-docker-compose.git app
```

更改mysql.env中的数据库密码

更改typecho.conf 中的域名为自己的域名

完成后使用`cd app`进入目录然后使用`docker-compose up -d`启动服务

浏览器输入`http://yourdomain.com`注意这里数据库填写db帐号填写typecho密码是自己改的

下一步会告诉你没有权限创建config.inc.php文件

使用`mv config.inc.php typecho`移动文件然后使用`nano config.inc.php`把数据库部分的内容填上`Ctrl+X`保存退出

接下来一路下一步就可以进入部署好的网站了

#### 全站开启SSL

使用acme.sh生成证书

```bash
./acme.sh --issue -d yourdomain.com -w /root/app/typecho
```

将证书拷贝到typecho目录下

取消注释config.inc.php中的

```php
define('__TYPECHO_SECURE__',true);
```

更改typecho.conf添加如下内容

```nginx
    location / {
        rewrite ^/(.*)$ https://yourdomain.com/$1 permanent;
    }
```

```nginx
server {
    listen 443 ssl http2;
    server_name your.awesome.blog;
    index index.html index.htm index.php;
    root /app;
    
    # cert
    ssl_certificate /app/fullchain.cer;
    ssl_certificate_key /app/yourdomain.com.key;

    # intermediate configuration. tweak to your needs.
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
    ssl_prefer_server_ciphers on;

    # openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
    #ssl_dhparam /app/dhparam.pem;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;

    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # fastcgi
    location ~ [^/]\.php(/|$) {
        fastcgi_pass php-fpm:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        set $path_info $fastcgi_path_info;
        fastcgi_param PATH_INFO $path_info;
        try_files $fastcgi_script_name =404;
        fastcgi_param  SCRIPT_FILENAME  /app/$fastcgi_script_name;
    }
}
```

由于Chrome浏览器对HTTPS要求较高，Firefox已经显示小绿锁，可是Chrome还是有警告提示，F12查看，评论表单的action地址还是HTTP，找到站点主题目录下的`comments.php`文件

搜索

`$this->commentUrl()`

将其替换为

`echo str_replace("http","https",$this->commentUrl());` 

最后保存

