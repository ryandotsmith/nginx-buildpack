#!/bin/bash
# Build NGINX and modules on Heroku.
# This program is designed to run in a web dyno provided by Heroku.
# We would like to build an NGINX binary for the builpack on the
# exact machine in which the binary will run.
# Our motivation for running in a web dyno is that we need a way to
# download the binary once it is built so we can vendor it in the buildpack.
#
# Once the dyno has is 'up' you can open your browser and navigate
# this dyno's directory structure to download the nginx binary.

NGINX_VERSION=1.6.2
PCRE_VERSION=8.21
HEADERS_MORE_VERSION=0.23
UPLOAD_VERSION=2.2
RESTY_VERSION=1.7.4.1

nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
pcre_tarball_url=http://garr.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.bz2
headers_more_nginx_module_url=https://github.com/agentzh/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz
upload_module_url=https://github.com/vkholodkov/nginx-upload-module/archive/${UPLOAD_VERSION}.tar.gz
resty_url=http://openresty.org/download/ngx_openresty-${RESTY_VERSION}.tar.gz

temp_dir=$(mktemp -d /tmp/nginx.XXXXXXXXXX)

echo "Serving files from /tmp on $PORT"
cd /tmp
python -m SimpleHTTPServer $PORT &

cd $temp_dir
echo "Temp dir: $temp_dir"

echo "Downloading $nginx_tarball_url"
curl -L $nginx_tarball_url | tar xzv

echo "Downloading $pcre_tarball_url"
(cd nginx-${NGINX_VERSION} && curl -L $pcre_tarball_url | tar xvj )

echo "Downloading $headers_more_nginx_module_url"
(cd nginx-${NGINX_VERSION} && curl -L $headers_more_nginx_module_url | tar xvz )

echo "Downloading $upload_module_url"
(cd nginx-${NGINX_VERSION} && curl -L $upload_module_url | tar xvz)

echo "Downloading $resty_url"
(curl -L $resty_url | tar xvz)

(
	cd nginx-${NGINX_VERSION}
	./configure \
		--with-pcre=pcre-${PCRE_VERSION} \
		--with-http_auth_request_module \
		--prefix=/tmp/nginx \
		--add-module=/${temp_dir}/nginx-${NGINX_VERSION}/headers-more-nginx-module-${HEADERS_MORE_VERSION} \
		--add-module=/${temp_dir}/nginx-${NGINX_VERSION}/nginx-upload-module-${UPLOAD_VERSION} \
		--add-module=/${temp_dir}/ngx_openresty-${RESTY_VERSION}/bundle/echo-nginx-module-0.56 \
		--add-module=/${temp_dir}/ngx_openresty-${RESTY_VERSION}/bundle/ngx_devel_kit-0.2.19 \
		--add-module=/${temp_dir}/ngx_openresty-${RESTY_VERSION}/bundle/set-misc-nginx-module-0.26
	make install
)

while true
do
	sleep 1
	echo "."
done
