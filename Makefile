
.PHONY: all usage doc
.PHONY: dist-gz dist-bz dist-xz dist dist-clean
.PHONY: install clean centos-docker
.PHONY: asciidoctor-docker-image do-asciidoctor-docker-image doc-clean

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

DIST_FILE_LIST = $(MAKEFILE_LIST) $(SRC_LIST) $(ADOC_LIST) $(EXTRA_DIST)

ASCIIDOCTOR_DOCKER_IMG = $(USER)/asciidoctor
ADOC_IMG_DOCKERFILE = docker/image/Dockerfile

usage:
	@echo "Create 'Makefile.cfg' file with :"
	@echo "  EXE_TGT = [ executable target ] or"
	@echo "  LIB_TGT = [ library target ]"
	@echo "  SRC_LIST = [ source files ]"
	@echo "  ADOC_LIST = [ adoc files ]"
	@echo "  GEN_PNG_LIST = [ generated PNG files ]"
	@echo "  DIST_NAME = [ distribution name ]"
	@echo "  DIST_VERSION = [ distribution version ]"
	@echo "  EXTRA_DIST = [ extra distribution files ]"
	@echo "  EXTRA_CLEAN = [ extra clean files ]"
	@echo "Usage : make [usage|all|doc|dist|install|clean|centos-docker]"
	@echo "  usage : display this usage"
	@echo "  all : create exe/lib and doc"
	@echo "  doc : create documentation"
	@echo "  dist (= dist-xz) : create distribution with format xz"
	@echo "  dist-gz : create distribution with format gz"
	@echo "  dist-bz : create distribution with format bz2"
	@echo "  install : install exe/lib in INSTALL_DIR directory"
	@echo "  clean : clean created files/directories"
	@echo "  centos-docker : start centos container"

all: $(EXE_TGT) $(LIB_TGT) doc

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

%.html: %.adoc
	[[ -n "$(OS_CYGWIN)" ]] && SRC_VOL=$$(cygpath -ma .) || SRC_VOL=.; \
	docker run -v "$$SRC_VOL":/documents $(ASCIIDOCTOR_DOCKER_IMG) \
	asciidoctor -r asciidoctor-diagram -o $@ $<

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
	rm -rf $(EXE_TGT) $(LIB_TGT) $(DOC_HTML_LIST) $(EXTRA_CLEAN)
	make dist-clean doc-clean

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
	rm -rf .asciidoctor docker $(GEN_PNG_LIST)

#DOCKERFILE###FROM centos
#DOCKERFILE###
#DOCKERFILE###RUN yum install -y ruby java python2 graphviz
#DOCKERFILE###
#DOCKERFILE###RUN gem install asciidoctor asciidoctor-pdf asciidoctor-diagram
#DOCKERFILE###RUN gem install coderay pygments.rb
#DOCKERFILE###
#DOCKERFILE###WORKDIR /documents
