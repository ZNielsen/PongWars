.PHONY: all test clean puml

# TOP_DIR must be included in base Makefile

SRC_DIR="$(TOP_DIR)/src"
IMG_DIR="$(SRC_DIR)/images"
TEST_DIR="$(TOP_DIR)/test"
BUILD_DIR="$(TOP_DIR)/build"
SUPPORT_DIR="$(TOP_DIR)/support"
BUILD_NUMBER_FILE="$(SRC_DIR)/pdxinfo"

SRC_FILES := $(shell find "$(SRC_DIR)" -name "*.lua" | tr '\n' ' ')
OUT_FILE := ice_hockey.pdx

TEST_FILES := $(shell find "$(TEST_DIR)" -name "*.lua" | tr '\n' ' ')
PUML_FILES := $(shell find "$(SUPPORT_DIR)" -name "*.puml" | tr '\n' ' ')
# Remove leading ./
PUML_FILES := $(foreach file, $(PUML_FILES), $(shell echo $(file) | sed 's/^\.\///g'))
PUML_PNGS := $(addsuffix .png, $(basename $(notdir $(PUML_FILES))))
PUML_PNGS := $(addprefix $(BUILD_DIR)/, $(PUML_PNGS))

MIRROR_PNGS  = $(IMG_DIR)/player.png
MIRROR_PNGS += $(IMG_DIR)/player_puck.png
MIRROR_PNGS  = $(IMG_DIR)/skater.png
MIRROR_PNGS += $(IMG_DIR)/skater_puck.png
MIRROR_PNGS += $(IMG_DIR)/goalie.png
MIRROR_PNGS += $(IMG_DIR)/goalie_puck.png

# Remove leading ./
IMG_DIR := $(foreach file, $(IMG_DIR), $(shell echo $(file) | sed 's/^\.\///g'))
# Modify names
MIRROR_PNGS := $(foreach file, $(MIRROR_PNGS), $(shell echo $(file) | sed 's/\(.*\).png/\1_mirror.png/g'))

all: $(OUT_FILE) $(MIRROR_PNGS)

release: all $(BUILD_NUMBER_FILE)

run: all
	@open $(BUILD_DIR)/$(OUT_FILE)

print:
	@echo $(MIRROR_PNGS)
	@echo $(IMG_DIR)

install:
	@brew install lua luarocks plantuml imagemagick
	@luarocks install busted

test: $(TEST_FILES)
	@busted $<

ice_hockey.pdx: $(SRC_FILES)
	@pdc --skip-unknown $(SRC_DIR) $(BUILD_DIR)/$@

clean:
	@rm -rf $(BUILD_DIR)/*

$(BUILD_NUMBER_FILE): $(SRC_FILES)
	$(TOP_DIR)/support/build_number_inc.sh $(TOP_DIR)

puml: $(PUML_PNGS)

$(BUILD_DIR)/%.png: %.puml
	@plantuml $< -o $(BUILD_DIR)

$(IMG_DIR)/%_mirror.png: $(IMG_DIR)/%.png
	@convert -flop $< $@
