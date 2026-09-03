#==============================================================#
# File      :   Makefile
# Desc      :   pgsty/deb repo shortcuts
# Ctime     :   2024-07-28
# Mtime     :   2026-09-03
# Path      :   Makefile
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   Apache-2.0
#==============================================================#

###############################################################
#                      1. Environment                         #
###############################################################
PIG_VERSION ?= v1.8.0
PUSH_RSYNC_ARGS := -avc --exclude=/apt/ --exclude=/tf/ --exclude=/tmp/

setup:
	@echo "curl -fsSL https://repo.pigsty.cc/pig | bash -s $(PIG_VERSION)"
	@echo "pig build spec"
	@echo "pig build repo"
	@echo "pig build tool"
	@echo "pig build rust"
	@echo "pig build pgrx"
	@echo "#pig build pkg <name...>"

ivorysql-contrib:
	$(MAKE) -C debbuild/ivorysql-contrib

###############################################################
#                        2. Building                          #
###############################################################
# noext install
deps:
	sudo dpkg -i ~/libduckdb_*.deb
	sudo dpkg -i ~/libfq_*.deb
	sudo dpkg -i ~/scws_*.deb


collect:
	mkdir -p /tmp/deb
	cp -r ~/*.deb /tmp/deb/ && find ~ -maxdepth 1 -type f -name '*.ddeb' -exec cp {} /tmp/deb/ \;



#---------------------------------------------#
# push to building machines
#---------------------------------------------#
push:
	rsync $(PUSH_RSYNC_ARGS) ./ d12:~/deb/
	rsync $(PUSH_RSYNC_ARGS) ./ d13:~/deb/
	rsync $(PUSH_RSYNC_ARGS) ./ u22:~/deb/
	rsync $(PUSH_RSYNC_ARGS) ./ u24:~/deb/
pushd:
	rsync $(PUSH_RSYNC_ARGS) --delete ./ d12:~/deb/
	rsync $(PUSH_RSYNC_ARGS) --delete ./ d13:~/deb/
	rsync $(PUSH_RSYNC_ARGS) --delete ./ u22:~/deb/
	rsync $(PUSH_RSYNC_ARGS) --delete ./ u24:~/deb/
push12:
	rsync $(PUSH_RSYNC_ARGS) ./ d12:~/deb/
push13:
	rsync $(PUSH_RSYNC_ARGS) ./ d13:~/deb/
push22:
	rsync $(PUSH_RSYNC_ARGS) ./ u22:~/deb/
push24:
	rsync $(PUSH_RSYNC_ARGS) ./ u24:~/deb/
pushd12:
	rsync $(PUSH_RSYNC_ARGS) --delete ./ d12:~/deb/
pushd13:
	rsync $(PUSH_RSYNC_ARGS) --delete ./ d13:~/deb/
pushd22:
	rsync $(PUSH_RSYNC_ARGS) --delete ./ u22:~/deb/
pushd24:
	rsync $(PUSH_RSYNC_ARGS) --delete ./ u24:~/deb/
push12a:
	rsync $(PUSH_RSYNC_ARGS) ./ d12a:~/deb/
push13a:
	rsync $(PUSH_RSYNC_ARGS) ./ d13a:~/deb/
push22a:
	rsync $(PUSH_RSYNC_ARGS) ./ u22a:~/deb/
push24a:
	rsync $(PUSH_RSYNC_ARGS) ./ u24a:~/deb/
pushm:
	rsync $(PUSH_RSYNC_ARGS) ./ meta:~/deb/

#---------------------------------------------#
# pull DEB packages from remote builders
#---------------------------------------------#
pull-new: pull-clean pull-init
pull-init:
	mkdir -p apt/bookworm apt/trixie apt/jammy apt/noble apt/resolute apt/meta
# resolute is collected from Docker and intentionally survives pull-new.
pull-clean:
	rm -rf   apt/bookworm apt/trixie apt/jammy apt/noble

pull: pull12 pull13 pull22 pull24 pull12a pull13a pull22a pull24a

pullx: pull12 pull13 pull22 pull24
pulla: pull12a pull13a pull22a pull24a

pullm:
	rsync -avc meta:~/ext/pkg/  apt/meta/

pull12:
	rsync -avc d12:~/ext/pkg/  apt/bookworm/
pull13:
	rsync -avc d13:~/ext/pkg/  apt/trixie/
pull22:
	rsync -avc u22:~/ext/pkg/  apt/jammy/
pull24:
	rsync -avc u24:~/ext/pkg/  apt/noble/
pull12a:
	rsync -avc d12a:~/ext/pkg/  apt/bookworm/
pull13a:
	rsync -avc d13a:~/ext/pkg/  apt/trixie/
pull22a:
	rsync -avc u22a:~/ext/pkg/  apt/jammy/
pull24a:
	rsync -avc u24a:~/ext/pkg/  apt/noble/

pullj:
	rsync -avc j2:~/ext/pkg/ apt/trixie/

upload:
	bin/upload.sh

# APT repository import and CDN publication live in ~/pgsty/repo/apt/Makefile.


###############################################################
#                      Push SPEC to Remote                    #
###############################################################
spec: spec12 spec13 spec22 spec24 spec12a spec13a spec22a spec24a
specm:
	rsync -az debbuild/ meta:~/debbuild/

spec12:
	rsync -az debbuild/ d12:~/debbuild/
spec13:
	rsync -az debbuild/ d13:~/debbuild/
spec22:
	rsync -az debbuild/ u22:~/debbuild/
spec24:
	rsync -az debbuild/ u24:~/debbuild/

spec12a:
	rsync -az debbuild/ d12a:~/debbuild/
spec13a:
	rsync -az debbuild/ d13a:~/debbuild/
spec22a:
	rsync -az debbuild/ u22a:~/debbuild/
spec24a:
	rsync -az debbuild/ u24a:~/debbuild/


###############################################################
#                      Push SRC to Remote                     #
###############################################################
# Update remote source tarball
src: src12 src13 src22 src24 src12a src13a src22a src24a
srcm:
	rsync -avz src/ meta:~/ext/src/
src12:
	rsync -avz src/ d12:~/ext/src/
src13:
	rsync -avz src/ d13:~/ext/src/
src22:
	rsync -avz src/ u22:~/ext/src/
src24:
	rsync -avz src/ u24:~/ext/src/

src12a:
	rsync -avz src/ d12a:~/ext/src/
src13a:
	rsync -avz src/ d13a:~/ext/src/
src22a:
	rsync -avz src/ u22a:~/ext/src/
src24a:
	rsync -avz src/ u24a:~/ext/src/

j: specj srcj
srcj:
	rsync -avz src/ j2:~/ext/src/
specj:
	rsync -az debbuild/ j2:~/debbuild/


###############################################################
#                         Terraform                           #
###############################################################
u:
	cd tf && terraform apply -auto-approve
	sleep 5
	tf/ssh
	sleep 15
	tf/ssh
a:
	cd tf && terraform apply
d:
	cd tf && terraform destroy -auto-approve
destroy:
	cd tf && terraform destroy
out:
	cd tf && terraform output
ssh:
	tf/ssh
r:
	git restore tf/terraform.tf


.PHONY: setup ivorysql-contrib deps collect \
	push pushd push12 push13 push22 push24 pushd12 pushd13 pushd22 pushd24 \
	push12a push13a push22a push24a pushm \
	pull-new pull-init pull-clean pull pullx pulla pullm \
	pull12 pull13 pull22 pull24 pull12a pull13a pull22a pull24a pullj upload \
	spec specm spec12 spec13 spec22 spec24 spec12a spec13a spec22a spec24a \
	src srcm src12 src13 src22 src24 src12a src13a src22a src24a \
	j srcj specj u a d destroy out ssh r
