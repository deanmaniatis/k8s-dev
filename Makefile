SHELL := /usr/bin/env bash

ifeq (, $(shell which multipass))
 $(error "No 'multipass' binary found in PATH, please install it from https://github.com/CanonicalLtd/multipass")
endif

VM_USER	 ?= multipass
VM_NAME  ?= k8s-dev
VM_CORES ?= 2
VM_MEM   ?= 4G
VM_DISK  ?= 10G
VM_MOUNT ?= /home/$(VM_USER)/mount# for lack of better mount folder name
PLAYBOOK ?= k8s-dev-playbook.yml

launch:
	@echo 'Launching $(VM_NAME) VM with $(VM_CORES) CPU cores, $(VM_MEM) memory and $(VM_DISK) disk size...'
	@multipass launch -n $(VM_NAME) -c $(VM_CORES) -m $(VM_MEM) -d $(VM_DISK) --cloud-init cloud-config.yaml
	@echo 'Waiting for cloud-init to finish:'
	@multipass exec -v $(VM_NAME) -- sh -c "cloud-init status --wait"
	@multipass mount . $(VM_NAME):$(VM_MOUNT)
	@multipass exec -v $(VM_NAME) -- sh -c "(cd $(VM_MOUNT); ansible-playbook $(VM_MOUNT)/$(PLAYBOOK))"

provision:
	multipass exec -v $(VM_NAME) -- sh -c "(cd $(VM_MOUNT); ansible-playbook -v $(VM_MOUNT)/$(PLAYBOOK))"
# multipass exec -v $(VM_NAME) -- sh -c "(cd $(VM_MOUNT); ansible-playbook -vv $(VM_MOUNT)/$(PLAYBOOK) --user $(VM_USER) )"

shell:
	@multipass shell $(VM_NAME)

start: 
	@multipass start $(VM_NAME)

stop:
	@multipass stop $(VM_NAME)

status:
	@multipass info $(VM_NAME)

clean:
	@multipass delete -p $(VM_NAME)

.PHONY: launch provision shell start stop status clean
