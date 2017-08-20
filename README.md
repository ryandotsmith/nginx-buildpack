Heroku Buildpack: NGINX
=======================

Nginx-buildpack vendors NGINX inside a dyno and connects NGINX to an app server via UNIX domain sockets.

This buildpack forks [Ryan Smith's excellent buildpack](https://github.com/ryandotsmith/nginx-buildpack) and maintains his feature list:

* Unified NGINX/App Server logs.
* [L2met](https://github.com/ryandotsmith/l2met) friendly NGINX log format.
* [Heroku request ids](https://devcenter.heroku.com/articles/http-request-id) embedded in NGINX logs.
* Crashes dyno if NGINX or App server crashes. Safety first.
* Language/App Server agnostic.
* Customizable NGINX config.
* Application coordinated dyno starts.

However there are some significant differences:

* NGINX is built during initial deployment, rather than using a prebuilt binary. The binary is cached between deploys.
* NGINX logs are sent directly to stderr rather than to the filesystem. This results in faster log delivery to Heroku logplex, and doesn't gradually fill the filesystem.
* Signals are handled gracefully by the wrapper script, allowing both the app and NGINX to stop properly on dyno shutdown.
* `PORT` is overridden to refer to the UNIX domain socket, so the application can detect whether it's running under NGINX or directly. This is especially because NGINX can be enabled or disabled at run-time by toggling `NGINX_ENABLED`.

Versions
--------

* [NGINX](http://nginx.org/) 1.12.1
* [PCRE](http://sourceforge.net/projects/pcre/) 8.41
* [ngx_headers_more](https://github.com/agentzh/headers-more-nginx-module) 0.32

These versions are tunable by setting `NGINX_VERSION`, `NGINX_PCRE_VERSION` and `NGINX_HEADERS_MORE_VERSION` in the app config, so you can update even if the buildpack hasn't bee updated yet.

Requirements
------------

* Your webserver listens to the socket at `/tmp/nginx.socket`.
* You can start your web server with a shell command.

Logging
-------

NGINX will output the following style of logs:

```
measure.nginx.service=0.007 request_id=e2c79e86b3260b9c703756ec93f8a66d
```

You can correlate this id with your Heroku router logs:

```
at=info method=GET path=/ host=salty-earth-7125.herokuapp.com request_id=e2c79e86b3260b9c703756ec93f8a66d fwd="67.180.77.184" dyno=web.1 connect=1ms service=8ms status=200 bytes=21
```

Language/App Server Agnostic
----------------------------

Nginx-buildpack provides a command named `bin/start-nginx` this command takes another command as an argument. You must pass your app server's startup command to `start-nginx`.

For example, to get NGINX and Unicorn up and running:

```bash
$ cat Procfile
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
```

### Application/Dyno coordination

The buildpack will not start NGINX until the application is listening on `/tmp/nginx-socket`. Since NGINX binds to the dyno's `PORT` and since the `PORT` determines if the app can receive traffic, you can delay NGINX accepting traffic until your application is ready to handle it. The examples below show how/when you should write the file when working with Unicorn.

### Setting the Worker Processes

You can configure NGINX's `worker_processes` directive via the `NGINX_WORKERS` environment variable.

For example, to set your `NGINX_WORKERS` to 8 on a PX dyno:

```bash
$ heroku config:set NGINX_WORKERS=8
```

Customizable NGINX Config
-------------------------

You can provide your own NGINX config by creating a file named `config/nginx.conf.erb` in your app. Start by copying the buildpack's [default config file](https://raw.githubusercontent.com/agriffis/nginx-buildpack/develop/config/nginx.conf.erb).

Alternatively, if you like the defaults, you can add a file `config/nginx-local.conf` and it will be included automatically.

### Patched Logging

This buildpack patches NGINX to send the access log directly to stderr, which is not a feature NGINX provides normally. If you override the default config and want to make use of this logging feature, use the following:

```
error_log stderr;

http {
    access_log error;
}
```

This instructs NGINX to send the error log to stderr (this is provided by NGINX upstream) and then to send the access log to the error log output (this is provided by the patch).

Examples
--------

### Ruby/Unicorn

#### Update Buildpacks

Use [heroku-buildpack-multii](https://github.com/agriffis/heroku-buildpack-multii) to load nginx-buildpack in addition to the Ruby buildpack.

```bash
$ heroku config:set BUILDPACK_URL=https://github.com/agriffis/heroku-buildpack-multii.git
$ echo 'https://github.com/agriffis/nginx-buildpack.git' >> .buildpacks
$ echo 'https://codon-buildpacks.s3.amazonaws.com/buildpacks/heroku/ruby.tgz' >> .buildpacks
$ git add .buildpacks
$ git commit -m 'Add multi-buildpack'
```

#### Update Unicorn Config

Listen on `ENV['PORT']` which will be the UNIX domain socket when running under NGINX.

```ruby
listen ENV['PORT']
```

#### Update Procfile

Prefix your server with `bin/start-nginx`.

```
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
```

### Python/Gunicorn

#### Update Buildpacks

Use [heroku-buildpack-multii](https://github.com/agriffis/heroku-buildpack-multii) to load nginx-buildpack in addition to the Python buildpack.

```bash
$ heroku config:set BUILDPACK_URL=https://github.com/agriffis/heroku-buildpack-multii.git
$ echo 'https://github.com/agriffis/nginx-buildpack.git' >> .buildpacks
$ echo 'https://github.com/heroku/heroku-buildpack-python.git' >> .buildpacks
$ git add .buildpacks
$ git commit -m 'Add multi-buildpack'
```

#### Update Gunicorn Config

Check for the UNIX domain socket and prefix with `unix:` for Gunicorn in `config/gunicorn.py`.

```python
import os

bind = os.environ['PORT']

if bind.startswith('/'):
    bind = 'unix:' + bind
```

#### Update Procfile

Prefix your server with `bin/start-nginx`.

```
web: bin/start-nginx gunicorn -c config/gunicorn.py
```

License
-------

* Copyright (c) 2013 Ryan R. Smith
* Copyright (c) 2014 Aron Griffis

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
