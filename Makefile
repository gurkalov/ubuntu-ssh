all: test

VERSION=$(or ${version},${version},latest)

PROJECT=ubuntu-ssh
PORT=2222
BASE_IMAGE=ubuntu:$(VERSION)
IMAGE=$(PROJECT):$(VERSION)
CONTAINER=$(PROJECT)-$(VERSION)
REPOSITORY=gurkalov
SSH_DIR=.ssh
SSH_KEY=id_rsa
SSH_LOCAL_KEYPUB=~/.ssh/id_rsa.pub

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

keygen: .FORCE
	make keyremove
	mkdir $(SSH_DIR)
	ssh-keygen -b 2048 -t rsa -f $(SSH_DIR)/$(SSH_KEY) -q -N ""

keyremove: .FORCE
	rm -r $(SSH_DIR) || true

run: .FORCE
	docker run -d -p $(PORT):22 -e SSH_KEY="$$(cat $(SSH_LOCAL_KEYPUB))" --name=$(CONTAINER) $(IMAGE)

up: .FORCE
	make keygen
	docker run -d -p $(PORT):22 -e SSH_KEY="$$(cat $(SSH_DIR)/$(SSH_KEY).pub)" --name=$(CONTAINER) $(IMAGE)

down: .FORCE
	make keyremove
	docker rm -f $(CONTAINER) || true

version: .FORCE
	while ! ssh root@localhost -i $(SSH_DIR)/$(SSH_KEY) -p $(PORT) -o "StrictHostKeyChecking=no" grep VERSION= /etc/*-release; do sleep 1; done

test: build .FORCE
	make clear
	make up
	make version
	make down

connect: .FORCE
	docker run -ti $(IMAGE) bash

release: .FORCE
	make test
	make push

.FORCE:
