.PHONY: all build run copy-files shell clean

# Docker image name
IMAGE_NAME = oci-repeater

# Docker container name
CONTAINER_NAME = oci-repeater-container

# Paths
MAIN_TF_EXAMPLE = ./resources/main.tf.example
MAIN_TF = ./resources/main.tf
CONFIG_EXAMPLE = ./resources/config.example
CONFIG = ./resources/config

.PHONY: setup copy-files build run

setup: copy-files build run

copy-files:
	if [ ! -f $(MAIN_TF) ]; then cp $(MAIN_TF_EXAMPLE) $(MAIN_TF); fi
	if [ ! -f $(CONFIG) ]; then cp $(CONFIG_EXAMPLE) $(CONFIG); fi

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run --name $(CONTAINER_NAME) -d $(IMAGE_NAME)

shell:
	docker exec -it $(CONTAINER_NAME) /bin/bash

clean:
	docker rm -f $(CONTAINER_NAME) || true
	docker rmi -f $(IMAGE_NAME) || true
