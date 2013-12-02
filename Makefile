
.PHONY: all dist-gz dist-bz dist-xz dist dist-clean install clean

include Makefile.cfg

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

all: $(EXE_TGT) $(LIB_TGT)

$(EXE_TGT): $(EXE_SRC_LIST)
	@echo "#!/bin/sh" > $@
	@for f in $(EXE_SRC_LIST); \
	do \
		echo "Cat: [$$f]->[$@]"; \
		echo "### Dist=[$(DIST_NAME)] File=[$$f]" >> $@; \
		cat $$f >> $@; \
	done
	@chmod a+x $@

$(LIB_TGT): $(LIB_SRC_LIST)
	@rm -f $@
	@for f in $(LIB_SRC_LIST); \
	do \
		echo "Cat: [$$f]->[$@]"; \
		echo "### Dist=[$(DIST_NAME)] File=[$$f]" >> $@; \
		cat $$f >> $@; \
	done

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
	for f in $(EXE_SRC_LIST) $(LIB_SRC_LIST) $(EXTRA_DIST); \
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
		mkdir -p $(INSTALL_BIN_DIR); \
		for f in $(INSTALL_BIN_FILE_LIST); \
		do \
			echo "Copy: [$$f]->[$(INSTALL_BIN_DIR)]"; \
			cp $$f $(INSTALL_BIN_DIR); \
			chmod a+x $(INSTALL_BIN_DIR)/$$(basename $$f); \
		done; \
	fi
	@if [ -n "$(INSTALL_LIB_FILE_LIST)" ]; \
	then \
		mkdir -p $(INSTALL_LIB_DIR); \
		for f in $(INSTALL_LIB_FILE_LIST); \
		do \
			echo "Copy: [$$f]->[$(INSTALL_LIB_DIR)]"; \
			cp $$f $(INSTALL_LIB_DIR); \
		done; \
	fi

clean:
	rm -rf $(EXE_TGT) $(LIB_TGT) $(EXTRA_CLEAN)
	make dist-clean
