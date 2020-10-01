
.PHONY: usage all init exe_lib_tgt doc
.PHONY: dist-gz dist-bz dist-xz dist dist-clean
.PHONY: install clean centos-docker
.PHONY: asciidoctor-docker-image do-asciidoctor-docker-image doc-clean
.PHONY: test-clean

OS = $(shell uname -o)
ifeq ($(OS),Cygwin)
OS_CYGWIN = T
endif

ifneq ($(MAKECMDGOALS),usage)
include Makefile.cfg
endif

ifeq ($(ADOC_LIST),)
ADOC_LIST = $(wildcard doc/*.adoc)
endif
DOC_HTML_LIST = $(ADOC_LIST:.adoc=.html)

INSTALL_BIN_FILE_LIST += $(EXE_TGT)
INSTALL_LIB_FILE_LIST += $(LIB_TGT)

DIST_TAR_Z = J
DIST_TAR_EXT = .tar.xz

ifeq ($(MAKECMDGOALS),install)
ifeq ($(INSTALL_DIR),)
$(error Define INSTALL_DIR variable)
endif
INSTALL_BIN_DIR = $(INSTALL_DIR)/bin
INSTALL_LIB_DIR = $(INSTALL_DIR)/lib
endif

MAKEFILE_LIST = Makefile Makefile.cfg

EXTRA_DIST_ALL = $(EXTRA_DIST) $(EXTRA_ADOC_INCLUDE)
DIST_FILE_LIST = $(MAKEFILE_LIST) $(SRC_LIST) $(ADOC_LIST) $(EXTRA_DIST_ALL)

ASCIIDOCTOR_DOCKER_IMG = $(USER)/asciidoctor
ADOC_IMG_DOCKERFILE = docker/doc/image/Dockerfile

CHANGELOG_ADOC_FILE = ChangeLog.adoc

usage:
	@echo "Create 'Makefile.cfg' file with :"
	@echo
	@echo "  EXE_TGT = [ executable target ] or"
	@echo "  LIB_TGT = [ library target ]"
	@echo "  SRC_LIST = [ source files ]"
	@echo "  ADOC_LIST = [ adoc files ]"
	@echo "  GEN_PNG_LIST = [ generated PNG files ]"
	@echo "  DIST_NAME = [ distribution name ]"
	@echo "  DIST_VERSION = [ distribution version ]"
	@echo "  EXTRA_DIST = [ extra distribution files ]"
	@echo "  EXTRA_CLEAN = [ extra clean files ]"
	@echo "  EXTRA_ADOC_INCLUDE = [ extra adoc include files ]"
	@echo
	@echo "Usage : make [usage|all|init|exe_lib_tgt|doc|"
	@echo "              dist|install|clean|centos-docker]"
	@echo
	@echo "  usage : display this usage (default)"
	@echo "  all : execute targets with *"
	@echo "  init (*) : initialize the project"
	@echo "  exe_lib_tgt (*) : create '$(EXE_TGT) $(LIB_TGT)'"
	@echo "  doc (*) : create documentation"
	@echo "  dist (= dist-xz) : create distribution with format xz"
	@echo "  dist-gz : create distribution with format gz"
	@echo "  dist-bz : create distribution with format bz2"
	@echo "  install : install exe/lib in INSTALL_DIR directory"
	@echo "  clean : clean created files/directories"
	@echo "  centos-docker : start centos container"

all:
	@for tgt in init exe_lib_tgt doc; \
	do \
		make $$tgt; \
	done

init:
	[ -f $(CHANGELOG_ADOC_FILE) -a -d doc -a \
		! -f doc/$(CHANGELOG_ADOC_FILE) ] && \
	cp $(CHANGELOG_ADOC_FILE) doc || \
	true

exe_lib_tgt: $(EXE_TGT) $(LIB_TGT)

$(EXE_TGT) $(LIB_TGT): $(SRC_LIST) $(MAKEFILE_LIST)
	@echo "#!/bin/sh" > $@
	@for f in $(SRC_LIST); \
	do \
		echo "Cat: [$$f]->[$@]"; \
		if [ "$$f" = "Makefile" ]; \
		then \
			cat $$f | sed -e "s|\\\\|\\\\\\\\|g" \
				-e "s|\\$$|\\\\$$|g" >> $@; \
		elif [ "$$f" = "src/main_tpl_makefile_eof" ]; \
		then \
			cat $$f >> $@; \
		else \
			echo "### Dist=[$(DIST_NAME)] File=[$$f]" >> $@; \
			cat $$f >> $@; \
		fi \
	done
	@chmod a+x $@

doc: asciidoctor-docker-image $(DOC_HTML_LIST)

doc/$(CHANGELOG_ADOC_FILE): $(CHANGELOG_ADOC_FILE)
	cp -f $< $@

%.html: %.adoc $(EXTRA_ADOC_INCLUDE)
	[[ -n "$(OS_CYGWIN)" ]] && SRC_VOL=$$(cygpath -ma .) || SRC_VOL=.; \
	docker run -v "$$SRC_VOL":/documents $(ASCIIDOCTOR_DOCKER_IMG) \
	asciidoctor -r asciidoctor-diagram -o $@ \
	-a DIST_VERSION=$(DIST_VERSION) $<

dist-gz:
	make dist DIST_TAR_Z="z" DIST_TAR_EXT=".tar.gz"

dist-bz:
	make dist DIST_TAR_Z="j" DIST_TAR_EXT=".tar.bz2"

dist-xz:
	make dist

dist:
	@make dist-clean; \
	DIST=$(DIST_NAME)-$(DIST_VERSION); \
	mkdir $$DIST; \
	for f in $(DIST_FILE_LIST); \
	do \
		SRC=$$f; \
		DST=$$DIST/$$f; \
		mkdir -p $$(dirname $$DST); \
		cp $$SRC $$DST; \
	done; \
	tar cv$(DIST_TAR_Z)f $$DIST$(DIST_TAR_EXT) $$DIST; \
	rm -rf $$DIST

dist-clean:
	rm -rf $(DIST_NAME)-$(DIST_VERSION)*

install: all
	@rm -rf $(INSTALL_DIR)
	@if [ -n "$(INSTALL_BIN_FILE_LIST)" ]; \
	then \
		INSTALL_FILE_LIST=$(INSTALL_BIN_FILE_LIST); \
		INSTALL_DST_DIR=$(INSTALL_BIN_DIR); \
	elif [ -n "$(INSTALL_LIB_FILE_LIST)" ]; \
	then \
		INSTALL_FILE_LIST=$(INSTALL_LIB_FILE_LIST); \
		INSTALL_DST_DIR=$(INSTALL_LIB_DIR); \
	fi; \
	mkdir -p $$INSTALL_DST_DIR; \
	for f in $$INSTALL_FILE_LIST; \
	do \
		echo "Copy: [$$f]->[$$INSTALL_DST_DIR]"; \
		cp $$f $$INSTALL_DST_DIR; \
		chmod a+x $$INSTALL_DST_DIR/$$(basename $$f); \
	done

clean:
	rm -rf $(EXE_TGT) $(LIB_TGT) $(EXTRA_CLEAN) tmp docker
	make dist-clean doc-clean test-clean

centos-docker: all
	[[ -n "$(OS_CYGWIN)" ]] && SRC_VOL=$$(cygpath -ma .) || SRC_VOL=.; \
	docker run -it -v "$$SRC_VOL":/home/soaf centos

asciidoctor-docker-image:
	@[ -z "$$(docker image ls -q $(ASCIIDOCTOR_DOCKER_IMG))" ] && \
	make do-asciidoctor-docker-image || true

do-asciidoctor-docker-image: $(ADOC_IMG_DOCKERFILE)
	cat $(ADOC_IMG_DOCKERFILE) | \
	docker build -t $(ASCIIDOCTOR_DOCKER_IMG) -

$(ADOC_IMG_DOCKERFILE): Makefile
	mkdir -p $$(dirname $@)
	TAG=DOCKERFILE; grep "#$$TAG" Makefile | sed -e "s/^#$$TAG###//" > $@

doc-clean:
	rm -f $(DOC_HTML_LIST) $(GEN_PNG_LIST) doc/$(CHANGELOG_ADOC_FILE)
	rm -rf .asciidoctor

test-clean:
	rm -rf test/log test/notif test/run test/tmp.* test/test.prop

#DOCKERFILE###FROM centos
#DOCKERFILE###
#DOCKERFILE###RUN yum install -y ruby java python2 graphviz
#DOCKERFILE###
#DOCKERFILE###RUN gem install asciidoctor asciidoctor-pdf asciidoctor-diagram
#DOCKERFILE###RUN gem install coderay pygments.rb
#DOCKERFILE###
#DOCKERFILE###WORKDIR /documents
