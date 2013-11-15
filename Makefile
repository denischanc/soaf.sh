
.PHONY: all clean dist

DIST_NAME = soaf
DIST_VERSION = \
  $(shell grep "_VERSION=" src/version.sh | awk -F\" '{print $$2}')

EXE = src/soaf.sh

EXE_SRC_LIST = \
  src/version.sh \
  src/util.sh \
  src/user.sh \
  src/cfg.sh \
  src/display.sh \
  src/roll.sh \
  src/log.sh \
  src/engine.sh \
  src/action.sh

EXTRA_DIST = Makefile

all: $(EXE)

$(EXE): $(EXE_SRC_LIST)
	cat $(EXE_SRC_LIST) > $@

dist:
	make dist-clean; \
	DIST=$(DIST_NAME)-$(DIST_VERSION); \
	mkdir $$DIST; \
	for f in $(EXE_SRC_LIST) $(EXTRA_DIST); \
	do \
		SRC=$$f; \
		DST=$$DIST/$$f; \
		mkdir -p $$(dirname $$DST); \
		cp $$SRC $$DST; \
	done; \
	tar cvJf $$DIST.tar.xz $$DIST; \
	rm -rf $$DIST

dist-clean:
	DIST=$(DIST_NAME)-$(DIST_VERSION); \
	rm -rf $$DIST $$DIST.tar.xz

clean:
	rm -f $(EXE)
	make dist-clean
