FROM    ubuntu:latest as builder
RUN     apt-get update && \
        apt-get install -y \
	automake bison build-essential g++ gcc libbison-dev libcurl4-openssl-dev libfl-dev libgeoip-dev liblmdb-dev libpcre3-dev libtool libxml2-dev libyajl-dev make pkg-config zlib1g-dev git curl libssl-dev
RUN	git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /tmp/modsecurity
RUN	cd /tmp/modsecurity && \
	git submodule init && \
	git submodule update && \
	./build.sh && ./configure && make && make install
RUN	git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /tmp/modsecurity-nginx
RUN	cd /tmp && \
	curl -O http://nginx.org/download/nginx-1.15.2.tar.gz && \
	tar xf nginx-1.15.2.tar.gz && \
	cd nginx-1.15.2 && \
	./configure --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --user=root --group=root --with-debug --with-http_ssl_module --add-module=/tmp/modsecurity-nginx/ --with-http_ssl_module --without-http_memcached_module --without-http_scgi_module --without-http_split_clients_module --without-http_ssi_module --without-http_uwsgi_module && \
	make && make install
	

#        git curl build-essential libpcre3 libpcre3-dev libssl-dev libtool autoconf apache2-dev libxml2-dev libcurl4-openssl-dev gcc libgeoip-dev
#RUN     git clone https://github.com/SpiderLabs/ModSecurity-nginx.git /usr/src/modsecurity
#RUN     cd /usr/src/modsecurity && \
#        ./autogen.sh && \
#        ./configure --enable-standalone-module --disable-mlogc && \
#        make
#RUN     cd /tmp && \
#        curl -O http://nginx.org/download/nginx-1.15.2.tar.gz && \
#        tar xf nginx-1.15.2.tar.gz && \
#        cd nginx-1.15.2 && \
##	./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/var/run/nginx.pid --lock-path=/var/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-ipv6 --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_geoip_module=dynamic --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-http_perl_module=dynamic --with-http_auth_request_module --with-mail=dynamic --with-mail_ssl_module --with-pcre --with-pcre-jit --with-stream=dynamic --with-stream_ssl_module --with-debug --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' --with-ld-opt=' -Wl,-E' && \
#        ./configure --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --user=root --group=root --with-debug --with-http_ssl_module --add-module=/usr/src/modsecurity/nginx/modsecurity --with-http_ssl_module --without-http_memcached_module --without-http_scgi_module --without-http_split_clients_module --without-http_ssi_module --without-http_uwsgi_module && \
#        make && \
#        make install

FROM	ubuntu
RUN     apt-get update && \
        apt-get install -y \
        libxml2 libcurl4 libaprutil1 vim
RUN	useradd nginx && \
        mkdir -p /var/log/nginx /usr/local/nginx/client_body_temp && \
	chown nginx:nginx /var/log/nginx /usr/local/nginx/client_body_temp
COPY   --from=builder /usr/local/nginx/sbin/nginx /usr/sbin
COPY   --from=builder /usr/local/modsecurity/lib /usr/local/modsecurity/lib
COPY   --from=builder /usr/lib/x86_64-linux-gnu/libGeoIP.so* /usr/lib/x86_64-linux-gnu/
COPY   --from=builder /usr/lib/x86_64-linux-gnu/libyajl.so* /usr/lib/x86_64-linux-gnu/
CMD	nginx -g 'daemon off;'
EXPOSE	80
