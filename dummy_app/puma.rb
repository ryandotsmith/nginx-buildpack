# Usage: bundle exec puma -C puma.rb -b unix:///tmp/nginx.socket

root = "#{Dir.getwd}"

workers 1
threads 2, 2

rackup "#{root}/config.ru"

# Support for nginx buildpack
# https://github.com/ashtonthomas/nginx-buildpack
# https://blog.codeship.com/how-to-deploy-nginx-on-heroku/
on_worker_fork do
  FileUtils.touch('/tmp/app-initialized')
end
