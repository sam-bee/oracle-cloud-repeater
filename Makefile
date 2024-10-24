.PHONY: setup copy-files build run clean

# Docker image name
IMAGE_NAME = oci-repeater

# Docker container name
CONTAINER_NAME = oci-repeater

# Paths
MAIN_TF_EXAMPLE = ./resources/main.tf.example
MAIN_TF = ./resources/main.tf
CONFIG_EXAMPLE = ./resources/config.example
CONFIG = ./resources/config

setup: copy-files build run

copy-files:
	if [ ! -f $(MAIN_TF) ]; then cp $(MAIN_TF_EXAMPLE) $(MAIN_TF); fi
	if [ ! -f $(CONFIG) ]; then cp $(CONFIG_EXAMPLE) $(CONFIG); fi

build:
	docker build -t $(CONTAINER_NAME) .

run:
	docker run -it $(CONTAINER_NAME)

clean:
	docker stop $(CONTAINER_NAME) || true
	docker kill $(CONTAINER_NAME) || true
	docker rm -f $(CONTAINER_NAME) || true
	docker rmi -f $(IMAGE_NAME) || true
