BASE_PATH:=$(shell pwd)
MY_IP:=$(shell curl -s -4 icanhazip.com)

generate_key:
	@mkdir -p ./temp
	@ssh-keygen -f ./temp/id_rsa -t rsa -b 4096 -q
	@chmod 400 ./temp/id_rsa

package_server:
	@rm -f ./temp/temp/server.zip
	@zip ./temp/server.zip -r server -x "*node_modules*"

test:
	cd server && npm run test

build:
	@docker build -t terraform .

deploy: build package_server
	docker run -it --rm -v $(BASE_PATH)/temp:/temp -v $(BASE_PATH)/plan:/plan --env-file ./default.env terraform \
		"terraform apply -auto-approve -state=/temp/terraform.tfstate -var 'localip=$(MY_IP)' -var-file=./plan/staging.tfvars ./plan"

teardown:
	@docker run -it --rm -v $(BASE_PATH)/temp:/temp -v $(BASE_PATH)/plan:/plan --env-file ./default.env terraform \
		"terraform destroy -auto-approve -state=/temp/terraform.tfstate -var 'localip=$(MY_IP)' -var-file=./plan/staging.tfvars ./plan"

