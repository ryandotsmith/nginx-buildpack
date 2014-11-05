# Heroku Buildpack: NGINX

This buildpack was forked from
https://github.com/ryandotsmith/nginx-buildpack but is taking
a slightly different approach by now.  

The basic idea: build from source and install NGINX inside a dyno
and allow that dyno to configure its operation. 

## Versions

The versions of nginx, PCRE, and the "headers_more" module are 
configured in scripts/build_nginx.sh

* NGINX Version: 1.6.2
* PCRE Version: 8.36 
* HEADERS_MORE Version: 0.25 

All are fetched from their authoritative homes (URLs configured
in build_nginx.sh as well).  Build is cached in the app cache 
so it should only compile nginx the first time you run it.  

To clear the cache and force a rebuild (say, for a new version of 
nginx) you can install the heroku-repo tool: 

https://github.com/heroku/heroku-repo

It adds a command to the heroku command line app to flush the 
buildpack cache.

## Features

* Unified NXNG/App Server logs.
* [L2met](https://github.com/ryandotsmith/l2met) friendly NGINX log format.
* [Heroku request ids](https://devcenter.heroku.com/articles/http-request-id) embedded in NGINX logs.
* Customizable NGINX config.

### Logging

NGINX will output the following style of logs:

```
measure.nginx.service=0.007 request_id=e2c79e86b3260b9c703756ec93f8a66d
```

You can correlate this id with your Heroku router logs:

```
at=info method=GET path=/ host=salty-earth-7125.herokuapp.com request_id=e2c79e86b3260b9c703756ec93f8a66d fwd="67.180.77.184" dyno=web.1 connect=1ms service=8ms status=200 bytes=21
```

### Setting the Worker Processes

You can configure NGINX's `worker_processes` directive via the
`NGINX_WORKERS` environment variable.

For example, to set your `NGINX_WORKERS` to 8 on a PX dyno:

```bash
$ heroku config:set NGINX_WORKERS=8
```

### Customizable NGINX Config

You can provide your own NGINX config by creating a file named
`nginx.conf.erb` in the config directory of your app. Start by
copying the buildpack's [default config
file](https://github.com/ryandotsmith/nginx-buildpack/blob/master/config/nginx.conf.erb).

### Customizable NGINX Compile Options

See [scripts/build_nginx.sh](scripts/build_nginx.sh) for the
build steps. Configuring is as easy as changing the "./configure"
options.

## License

Copyright (c) 2013 Ryan R. Smith
Copyright (c) 2014 Thinkful 

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions: The above copyright notice and this permission notice
shall be included in all copies or substantial portions of the
Software.  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
