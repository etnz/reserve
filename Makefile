include vars.env

PACKAGES := $(wildcard */nfpm.yaml)
DEBS := $(patsubst %/nfpm.yaml,dist/%.deb,$(PACKAGES))

TEMPLATES := $(wildcard **.t)
FLATS := $(patsubst %.t,%,$(TEMPLATES))


.PHONY: all build install-tools clean

all: install-tools build

clean:
	rm -rf dist/

install-tools:
	go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
	go install github.com/etnz/apt-repo-builder@master


dist/%.deb: %/nfpm.yaml vars.env
	@echo "Building package $*..."
	@mkdir -p dist
	@cd $* && nfpm pkg --config nfpm.yaml --packager deb --target ../$@

# Package specific dependencies
# dist/letter-of-introduction.deb: letter-of-introduction/postinst letter-of-introduction/prerm

dist/private.key:
	@echo "Generating temporary for test GPG key..."
	@mkdir -p dist
	@gpg --list-keys "Petit Bijou" > /dev/null 2>&1 || gpg --batch --passphrase '' --quick-gen-key "Petit Bijou" default default
	gpg --armor --export-secret-keys "Petit Bijou" > $@

dist/Release: dist/private.key $(DEBS)
	@echo "Building APT Repository..."
	@export GPG_PRIVATE_KEY=$$(cat dist/private.key) && \
	apt-repo-builder index-local --config apt-repo-builder.yaml

repo: dist/Release

build: $(DEBS)
