build: build-cedar-14 build-heroku-16

build-cedar-14:
	@echo "Building Nginx in docker for cedar-14..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=cedar-14" -w /buildpack heroku/cedar:14 scripts/build_nginx /buildpack/bin/nginx-cedar-14

build-heroku-16:
	@echo "Building Nginx in docker for heroku-16..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-16" -w /buildpack heroku/heroku:16-build scripts/build_nginx /buildpack/bin/nginx-heroku-16

shell:
	@echo "Opening heroku-16 shell..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-16" -e "PORT=5000" -w /buildpack heroku/heroku:16 bash
