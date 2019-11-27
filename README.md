使用

```bash
git clone --recursive https://github.com/FaintGhost/typecho-docker-compose.git app
```

克隆仓库

更改mysql.env中的密码

更改typecho.conf 中的域名

使用acme.sh生成证书

```bash
./acme.sh --issue -d test.faintghost.com -w /root/app/typecho
```

由于Chrome浏览器对HTTPS要求较高，Firefox已经显示小绿锁，可是Chrome还是有警告提示，F12查看，评论表单的action地址还是HTTP，找到站点主题目录下的`comments.php`文件，并搜索`$this->commentUrl()`,将其替换为：`echo str_replace("http","https",$this->commentUrl());` 最后保存。 

```nginx
    location / {
        rewrite ^/(.*)$ https://test.faintghost.com/$1 permanent;
    }
```

```nginx
server {
    listen 443 ssl http2;
    server_name test.faintghost.com;
    index index.html index.htm index.php;
    root /app;
    
    # cert
    ssl_certificate /app/fullchain.cer;
    ssl_certificate_key /app/test.faintghost.com.key;

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

