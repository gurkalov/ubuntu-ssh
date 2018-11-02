all: test

VERSION=$(or ${version},${version},latest)

PROJECT=ubuntu-ssh
PORT=2222
BASE_IMAGE=ubuntu:$(VERSION)
IMAGE=$(PROJECT):$(VERSION)
CONTAINER=$(PROJECT)-$(VERSION)
REPOSITORY=gurkalov

clear: .FORCE
	docker ps -a -q --filter name=$(PROJECT) | xargs --no-run-if-empty docker rm -f

push: .FORCE
	docker tag $(IMAGE) $(REPOSITORY)/$(IMAGE)
	docker push $(REPOSITORY)/$(IMAGE)

pull: .FORCE
	docker pull $(BASE_IMAGE)

build: .FORCE
	docker build --build-arg VERSION=$(VERSION) -t $(IMAGE) .

rebuild: pull .FORCE
	docker build --build-arg VERSION=$(VERSION) --no-cache -t $(IMAGE) .

up: .FORCE
	docker run -d -p $(PORT):22 -e SSH_KEY="$$(cat ~/.ssh/id_rsa.pub)" --name=$(CONTAINER) $(IMAGE)
	sleep 1

down: .FORCE
	docker rm -f $(CONTAINER)

version: .FORCE
	ssh root@localhost -p $(PORT) -o "StrictHostKeyChecking=no" grep VERSION= /etc/*-release

test: build .FORCE
	make up
	make version
	make down

connect: .FORCE
	docker run -ti $(IMAGE) bash

release: .FORCE
	make test
	make push

.FORCE:
