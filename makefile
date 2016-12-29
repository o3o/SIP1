NAME = si.exe
VERSION = 0.1.0
TARGET = exe

ROOT_SOURCE_DIR = src
getSources = $(shell find $(ROOT_SOURCE_DIR) -name "*.cs")
SRC = $(getSources)

REFS = System.Data.dll SimpleInjector.dll
REFS_FLAG = $(addprefix -r:, $(REFS))


ZIP = $(BIN)/$(NAME)
ZIP += $(wildcard config/*.yaml)

ZIP_SRC = $(ZIP) $(SRC) README.md CHANGELOG.md makefile $(SRC_TEST)

########
# Test #
########
TEST_SOURCE_DIR = tests
SRC_TEST = $(filter-out $(ROOT_SOURCE_DIR)/App.cs, $(SRC))
SRC_TEST += $(wildcard $(TEST_SOURCE_DIR)/*.cs)

REFS_TEST = $(REFS)
REFS_TEST += nunitlite.dll
REFS_TEST += nunit.framework.dll
REFS_TEST += NSubstitute.dll
REFS_TEST += Ploeh.AutoFixture.dll
REFS_FLAG_TEST = $(addprefix -r:, $(REFS_TEST))
PKG_FLAG_TEST = $(PKG_FLAG)

###############
# Common part #
###############
BIN = bin
CSC = mcs

BASE_NAME = $(basename $(NAME))
#CSCFLAGS += -debug
#ISO-1, ISO-2, 3, 4, 5, Default or Experimental
#CSCFLAGS += -langversion:3
#anycpu|anycpu32bitpreferred|arm|x86|x64|itanium
CSCFLAGS += -platform:x86
# vedere /usr/lib/mono
CSCFLAGS += -sdk:4.5
CSCFLAGS += -nologo
CSCFLAGS += -target:$(TARGET)
CSCFLAGS += -lib:$(BIN)
CSCFLAGS += $(RES_OPT)

NAME_TEST = test-runner
CSCFLAGS_TEST += -debug -nologo -target:exe
CSCFLAGS_TEST += -lib:$(BIN)

NUNIT_OPT =--noheader --noresult

PUBLISH_DIR = $(CS_DIR)/lib/Microline/$(BASE_NAME)/$(VERSION)
ZIP_PREFIX = $(BASE_NAME)-$(VERSION)

.PHONY: all clean clobber test testv ver var pkgall pkg pkgtar pkgsrc publish

DEFAULT: all
all: builddir $(BIN)/$(NAME)

WHERE += $(if $(W), --where "$(W)")

## make test W=test_name T=option
test: builddir $(BIN)/$(NAME_TEST)
	$(BIN)/$(NAME_TEST) $(NUNIT_OPT) $(T) $(WHERE)

testv: builddir $(BIN)/$(NAME_TEST)
	$(BIN)/$(NAME_TEST) $(NUNIT_OPT) -v $(T) $(WHERE)

builddir:
	@mkdir -p $(BIN)

$(BIN)/$(NAME): $(SRC) | builddir
	$(CSC) $(CSCFLAGS) $(REFS_FLAG) $(PKG_FLAG) -out:$@ $^

$(BIN)/$(NAME_TEST): $(SRC_TEST) | builddir
	$(CSC) $(CSCFLAGS_TEST) $(REFS_FLAG_TEST) $(PKG_FLAG_TEST) -out:$@ $^

pkgdir:
	@mkdir -p pkg

pkgall: pkg pkgtar pkgsrc

pkg: pkgdir | pkg/$(ZIP_PREFIX).zip

pkg/$(ZIP_PREFIX).zip: $(ZIP)
	zip $@ $(ZIP)

pkgtar: pkgdir | pkg/$(ZIP_PREFIX).tar.bz2

pkg/$(ZIP_PREFIX).tar.bz2: $(ZIP)
	tar -jcf $@ $^

pkgsrc: pkgdir | pkg/$(ZIP_PREFIX)-src.tar.bz2

	pkg/$(ZIP_PREFIX)-src.tar.bz2: $(ZIP_SRC)
	tar -jcf $@ $^
changelog: CHANGELOG.txt

CHANGELOG.txt: CHANGELOG.md
	pandoc -f markdown_github -t plain $^ > $@

publishdir:
	@mkdir -p $(PUBLISH_DIR)

publish: publishdir
	cp -u --verbose --backup=t --preserve=all $(BIN)/$(NAME) $(PUBLISH_DIR)

tags: $(SRC)
	ctags $^

ver:
	@echo $(VERSION)

clean:
	-rm -f $(BIN)/$(NAME)
	-rm -f $(BIN)/$(NAME_TEST)
	-rm -f $(BIN)/*.mdb

clobber: clean
	-rm -Rf $(BIN)/*.dll

var:
	@echo NAME:$(NAME)
	@echo SRC:$(SRC)
	@echo
	@echo REFS: $(REFS)
	@echo REFS_FLAG: $(REFS_FLAG)
	@echo PKG_FLAG: $(PKG_FLAG)
	@echo
	@echo CSCFLAGS: $(CSCFLAGS)
	@echo
	@echo SRC_TEST:$(SRC_TEST)
	@echo
	@echo REFS_TEST: $(REFS_TEST)
	@echo REFS_FLAG_TEST: $(REFS_FLAG_TEST)
	@echo PKG_FLAG_TEST: $(PKG_FLAG_TEST)
	@echo
	@echo CSCFLAGS_TEST: $(CSCFLAGS_TEST)
	@echo
	@echo ZIP: $(ZIP)
	@echo
	@echo VERSION: $(VERSION)

#include i18n.makefile
