DOCKER := docker
DOCKER_OPTS :=

all:
	$(DOCKER) build $(DOCKER_OPTS) "$(PWD)" -f "Dockerfile" -t jpereiran/devbox-freeradius-server-hostap
