
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

MAKEFILE_LIST = Makefile Makefile.cfg

DIST_FILE_LIST = $(MAKEFILE_LIST) $(SRC_LIST) $(EXTRA_DIST)

all: $(EXE_TGT) $(LIB_TGT)

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
	rm -rf $(EXE_TGT) $(LIB_TGT) $(EXTRA_CLEAN)
	make dist-clean
