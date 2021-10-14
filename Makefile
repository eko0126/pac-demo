#Copyright [eko0126] [name of copyright owner]
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

SHELL:=/bin/bash
.PHONY: test build deploy tag flyway run unti_test build_jar build_image deploy_with_tag

APP_NAME := "pac-demo"
GIT_SHORT_SHA := $(shell git rev-parse --short=8 HEAD)
GIT_TAG := $(shell git describe --exact-match --tags HEAD 2>/dev/null)
IMAGE_REPOSITORY := "echohe/pac-demo"
K8S_ENV ?= dev
IMGAE_TAG ?= $(GIT_SHORT_SHA)

test: unit_test

build: build_jar build_image

deploy:
	@docker run -i --rm \
	-v $(PWD):/work \
	-w /work \
	-v $(HOME)/.kube:/root/.kube \
	-e HELM_DRIVER=configmap \
	alpine/helm:3.7.0 \
	upgrade $(APP_NAME) chart --create-namespace -i \
	-n $(K8S_ENV)-noah  \
	--set image.repository="$(IMAGE_REPOSITORY)" \
	--set image.pullPolicy=Always \
	--set image.tag=$(IMGAE_TAG) \
	--set service.type=$(SERVICE_TYPE) \
	--set service.port=8080 \
	--kubeconfig /root/.kube/$(K8S_ENV)-minikube-config \
	--wait --timeout 300s

deploy_with_tag: IMGAE_TAG=$(GIT_TAG)
deploy_with_tag: deploy

run: build_jar
	@docker run --rm -it \
	-v $(PWD):/app \
	-p 8080:8080 \
	amazoncorretto:11.0.12 \
	/app/entrypoint

flyway:
	@docker run --rm -i\
	-v $(PWD):/work \
	-w /work \
	-v $(HOME)/.flyway:/conf \
	flyway/flyway:7.7.1 \
	-locations=filesystem:/myworkspace/flyway \
	-schemas=dms \
	-configFiles=/conf/$(K8S_ENV)_flyway.conf \
	info migrate info

tag:
	@docker run --rm -i \
	--entrypoint '' \
	-v ${HOME}/.docker/config.json:/root/.docker/config.json \
	harbor.wti-xa.com/library/gcr/crane:debug  \
	sh -c "crane --insecure tag \
	$(IMAGE_REPOSITORY)/$(APP_NAME):$(GIT_SHORT_SHA)-$(CI_PROJECT_PATH_SLUG) \
	$(GIT_TAG)-$(CI_PROJECT_PATH_SLUG) &&\
	crane --insecure tag \
	$(IMAGE_REPOSITORY)/$(SERVICE_NAME):$(GIT_SHORT_SHA)-$(CI_PROJECT_PATH_SLUG) \
	$(GIT_TAG)-$(CI_PROJECT_PATH_SLUG)"

build_jar:
	@docker run -i --rm \
	-v $(PWD):/work \
	-w /work \
	gradle:7.2.0-jdk11 \
	gradle clean bootJar

build_image:
	@docker run -i --rm \
	-v $(PWD):/work \
	-v $(HOME)/kaniko:/kaniko/.docker \
	-w /work \
	gcr.io/kaniko-project/executor:v1.6.0 \
	-c /work \
	-f Dockerfile \
	-d "$(IMAGE_REPOSITORY):$(GIT_SHORT_SHA)" 

unit_test:
	@docker run -i --rm \
	-v $(PWD):/work \
	-w /work \
	gradle:7.2.0-jdk11 \
	gradle clean test

ifeq ($(K8S_ENV),dev)
  SERVICE_TYPE := NodePort
endif
