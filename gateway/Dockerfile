FROM openresty/openresty:alpine-fat
RUN apk add --no-cache geoip geoip-dev

# Скачайте базу стран
RUN mkdir -p /usr/share/GeoIP && \
    wget -O /usr/share/GeoIP/GeoIP.dat "https://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz" && \
    gunzip /usr/share/GeoIP/GeoIP.dat.gz

RUN luarocks install lua-resty-jwt