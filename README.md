# MTProxy mtproto-proxy mtproto-proxy-server


## Installing

```bash
git clone https://github.com/an-ivannikov/mtproto-proxy-server.git
cd mtproto-proxy-server
sudo sh ./install.sh
```

## Register your proxy with @MTProxybot on Telegram.

> <host>:<port>
> mtproto-secret

## Activate promotion

```bash
echo "proxy-tag from @MTProxybot" > /var/www/mtproto-proxy/proxy-tag
cd /var/www/mtproto-proxy-server
sudo sh ./scripts/mtproto-proxy-install-service.sh
```
