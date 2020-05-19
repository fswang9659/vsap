# Copyright (c) 2020 Intel and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

vpp_vcl_patch_dir          := $(CURDIR)/vpp_patches
vpp_vcl_src_dir            := $(CURDIR)/vpp
vpp_vcl_install_dir        := $(I)/local
vpp_vcl_pkg_deb_name       := vpp
vpp_vcl_pkg_deb_dir        := $(CURDIR)/vpp/build-root
vpp_vcl_desc               := "vcl vpp"


define  vpp_vcl_extract_cmds
	@true
endef

define  vpp_vcl_patch_cmds
	@echo "--- vpp patching ---"
	@cd $(vpp_vcl_src_dir); \
		git reset --hard; git clean -f; git checkout master; \
		if [ ! -z $(_VPP_VER) -a $(_VPP_VER) != "master" ]; then \
			echo "--- vpp version: $(_VPP_VER) ---"; \
			git checkout origin/stable/$(_VPP_VER); \
			git reset --hard; git clean -f; \
		fi
	@for f in $(CURDIR)/vpp_patches/common/*.patch ; do \
		echo Applying patch: $$(basename $$f) ; \
		patch -p1 -d $(vpp_vcl_src_dir) < $$f ; \
	done
	@if [ -z $(_VPP_VER) -o $(_VPP_VER) = "master" ]; then \
		echo "--- vpp master ---"; \
		for f in $(CURDIR)/vpp_patches/common/master/*.patch ; do \
			echo Applying patch: $$(basename $$f) ; \
			patch -p1 -d $(vpp_vcl_src_dir) < $$f ; \
		done; \
	elif [ $(_VPP_VER) = "2001" ]; then \
		echo "--- vpp 20.01 ---"; \
		for f in $(CURDIR)/vpp_patches/common/2001/*.patch ; do \
			echo Applying patch: $$(basename $$f) ; \
			patch -p1 -d $(vpp_vcl_src_dir) < $$f ; \
		done; \
	fi
	@for f in $(CURDIR)/vpp_patches/vcl/*.patch ; do \
		echo Applying patch: $$(basename $$f) ; \
		patch -p1 -d $(vpp_vcl_src_dir) < $$f ; \
		done

	@true
endef


define  vpp_vcl_config_cmds
	@true
endef

define  vpp_vcl_build_cmds
	@cd $(vpp_vcl_src_dir); \
		echo "--- build : $(vpp_vcl_src_dir)"; \
		export OPENSSL_ROOT_DIR=$(I)/local/ssl; \
		export LD_LIBRARY_PATH=$(I)/local/ssl/lib; \
		$(MAKE) wipe-release; \
		rm -f $(vpp_vcl_pkg_deb_dir)/*.deb; \
		$(MAKE) build-release; \
		$(MAKE) pkg-deb;
endef

define  vpp_vcl_install_cmds
	@true
endef

define  vpp_vcl_pkg_deb_cmds
	@true
endef

define  vpp_vcl_pkg_deb_cp_cmds
	@echo "--- move deb to $(CURDIR)/dev-vcl ---"
	@mkdir -p deb-vcl
	@rm -f deb-vcl/*
	@mv $(I)/openssl-deb/*.deb deb-vcl/.
	@rm $(B)/.openssl.pkg-deb.ok
	@mv $(vpp_vcl_pkg_deb_dir)/*.deb deb-vcl/.
endef

$(eval $(call package,vpp_vcl))
