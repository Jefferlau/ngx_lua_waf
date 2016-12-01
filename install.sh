#!/usr/bin/env bash

yum install -y gcc gcc-c++
yum install -y pcre-devel
yum install -y zlib-devel
yum install -y openssl-devel

tmpdir="/opt/lua-nginx"
mkdir -p $tmpdir
cd $tmpdir
if [ ! -x "LuaJIT-2.1.0-beta2.tar.gz" ]; then
wget http://luajit.org/download/LuaJIT-2.1.0-beta2.tar.gz
fi
tar zxf LuaJIT-2.1.0-beta2.tar.gz
cd LuaJIT-2.1.0-beta2
make
make install PREFIX=/usr/local/lj2
ln -s /usr/local/lj2/lib/libluajit-5.1.so.2.1.0 /lib64/liblua-5.1.so
cd $tmpdir
if [ ! -x "v0.3.0.tar.gz" ]; then
wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz
fi
tar zxf v0.3.0.tar.gz
if [ ! -x "v0.10.7.tar.gz" ]; then
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.7.tar.gz
fi
tar zxf v0.10.7.tar.gz
#cd $tmpdir
#if [ ! -x "pcre-8.39.tar.gz" ]; then
#wget https://sourceforge.net/projects/pcre/files/pcre/8.39/pcre-8.39.tar.gz
#fi
#tar zxvf pcre-8.39.tar.gz
#cd pcre-8.39/
#./configure --prefix=/usr/local/pcre
#make && make install
cd $tmpdir
if [ ! -x "nginx-1.11.6.tar.gz" ]; then
wget 'http://nginx.org/download/nginx-1.11.6.tar.gz'
fi
tar -xzvf nginx-1.11.6.tar.gz
cd nginx-1.11.6
export LUAJIT_LIB=/usr/local/lj2/lib/
export LUAJIT_INC=/usr/local/lj2/include/luajit-2.1/

#   --with-pcre=$tmpdir/pcre-8.39 \
./configure --user=daemon --group=daemon\
    --prefix=/usr/local/nginx \
    --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
    --with-openssl=/usr/include \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_gzip_static_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module  \
    --add-module=$tmpdir/ngx_devel_kit-0.3.0 \
    --add-module=$tmpdir/lua-nginx-module-0.10.7

#./configure --user=daemon --group=daemon --prefix=/usr/local/nginx/ --with-http_stub_status_module --with-http_sub_module --with-http_gzip_static_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module  --add-module=../ngx_devel_kit-0.2.17rc2/ --add-module=../lua-nginx-module-0.7.4/
make -j8
make install 
#rm -rf $tmpdir
cd /usr/local/nginx/conf/
#wget https://github.com/loveshell/ngx_lua_waf/archive/master.zip --no-check-certificate
#unzip master.zip
#mv ngx_lua_waf-master/* /usr/local/nginx/conf/
#rm -rf ngx_lua_waf-master
#rm -rf $tmpdir
mkdir -p ../logs/hack
chmod -R 775 ../logs/hack
echo "安装成功！"
echo "======================= 使用说明 ============================="
echo "把网站防火墙代码上传到 conf 目录下,解压命名为 waf "
echo ""
echo "在 nginx.conf 的 http 段添加如下四行代码"
echo ""
echo "        lua_package_path \"/usr/local/nginx/conf/waf/?.lua\";"
echo "        lua_shared_dict limit 10m;"
echo "        init_by_lua_file  /usr/local/nginx/conf/waf/init.lua;"
echo "        access_by_lua_file /usr/local/nginx/conf/waf/waf.lua;"
echo ""
echo "配置 config.lua 里的 waf 规则目录(在 waf/conf/ 目录下)"
echo ""
echo "        RulePath = \"/usr/local/nginx/conf/waf/wafconf/\""
echo ""
echo "绝对路径如有变动，需对应修改"
echo "然后重启 Nginx 即可。"
echo ""