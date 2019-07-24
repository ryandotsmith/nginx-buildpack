#!/usr/bin/env bash

echo "# Cloudflare" > config/00_real_ip_cloudflare_00.conf
for i in 'curl https://www.cloudflare.com/ips-v4'; do
        echo "set_real_ip_from $i;" >> config/00_real_ip_cloudflare_00.conf
done

for i in 'curl https://www.cloudflare.com/ips-v6'; do
        echo "set_real_ip_from $i;" >> config/00_real_ip_cloudflare_00.conf
done
