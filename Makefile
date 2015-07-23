ifeq ($(OS),Windows_NT)
export NODE_PATH=$(APPDATA)/npm/node_modules
endif

all: js css

# Rules to minify our .js files
js: js/jsonl.min.js
%.min.js: %.js
	uglifyjs "$^" > "$@"
js/%.js: %.grammar.js
	node "$^" > "$@"

.PRECIOUS: js/%.js


# Rules to run Stylus on our .css files
css: css/kb.css
css/%.css: %.css
	stylus --out css -c -m --inline --with {limit:1024} $^


# Rules to generate a webfont from our source .svg files
fonts: fonts/kbd-custom.ttf

kbd-custom-glyphs := \
	font-src/logo-windows-7.svg \
	font-src/logo-windows-8.svg \
	font-src/logo-apple.svg \
	font-src/logo-apple-outline.svg \
	font-src/logo-vim.svg \
	font-src/logo-commodore.svg \
	font-src/logo-amiga.svg \
	font-src/logo-ubuntu_cof.svg \
	font-src/logo-ubuntu_cof-circle.svg \
	font-src/logo-linux-tux.svg \
	font-src/logo-linux-tux-ibm.svg \
	font-src/logo-linux-tux-ibm-invert.svg \
	font-src/community-hapster.svg \
	font-src/community-awesome.svg \
	font-src/community-awesome-invert.svg \

define _CUSTOM_FONT 
fonts: fonts/$(1)
fonts/$(1): font-src/$(basename $(1)).sfd font-src/$(basename $(1)).pe $(2)
	fontforge -script "font-src/$(basename $(1)).pe" "$$<" "$$@"
endef
CUSTOM_FONT = $(eval $(call _CUSTOM_FONT,$(1).ttf,$(2)))$(eval $(call _CUSTOM_FONT,$(1).eot,$(2)))$(eval $(call _CUSTOM_FONT,$(1).svg,$(2)))$(eval $(call _CUSTOM_FONT,$(1).woff,$(2)))

$(call CUSTOM_FONT,kbd-custom,$(kbd-custom-glyphs))

test:
	protractor tests/conf.js

install:
	bower install
	cd bower_components/angular-ui-bootstrap
	npm install
	grunt before-test after-test
	cd ../angular-ui-utils
	npm install
	grunt build
	cd ../..
