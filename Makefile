.PHONY: all new new-variant preview export clean cleanall list help

COMPILER := latexmk
FLAGS ?= -pdf -interaction=nonstopmode -halt-on-error

VARIANT ?= base
TAILORED ?=
FROM ?= base

# Set your fullname to prefix tailored resume files, for example: jane_doe
FULLNAME ?=

EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
FULLNAME_PREFIX := $(if $(strip $(FULLNAME)),$(subst $(SPACE),_,$(strip $(FULLNAME)))_,)
TAILORED_NAME := $(FULLNAME_PREFIX)$(TAILORED)

VARIANT_DIR := variants
TAILORED_DIR := tailored
BUILD_DIR := build
OUT_DIR := out

VARIANT_TEX := $(VARIANT_DIR)/$(VARIANT).tex
FROM_TEX := $(VARIANT_DIR)/$(FROM).tex
TAILORED_TEX := $(TAILORED_DIR)/$(TAILORED_NAME).tex

ifeq ($(TAILORED),)
SOURCE := $(VARIANT_TEX)
OUTPUT_NAME := $(VARIANT)
else
SOURCE := $(TAILORED_TEX)
OUTPUT_NAME := $(TAILORED_NAME)
endif

define CHECK_SOURCE
@test -f "$(SOURCE)" || { \
	if [ -n "$(TAILORED)" ]; then \
		echo "Tailored resume not found: $(SOURCE)"; \
		echo "Create it with: make new TAILORED=$(TAILORED) VARIANT=$(VARIANT)"; \
	else \
		echo "Variant resume not found: $(SOURCE)"; \
	fi; \
	exit 1; \
}
endef

define CHECK_NAME
@if [ -n "$($(1))" ] && ! printf '%s\n' "$($(1))" | grep -Eq '^[A-Za-z0-9_-]+$$'; then \
	echo "$(1) must contain only letters, numbers, underscores, and hyphens: $($(1))"; \
	exit 1; \
fi
endef

all: | $(BUILD_DIR)
	$(call CHECK_NAME,VARIANT)
	$(call CHECK_NAME,TAILORED)
	$(call CHECK_NAME,FULLNAME)
	$(CHECK_SOURCE)
	$(COMPILER) $(FLAGS) -jobname=$(OUTPUT_NAME) -outdir=$(BUILD_DIR) $(SOURCE)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

new:
	@test -n "$(TAILORED)" || { echo "Usage: make new TAILORED=name [VARIANT=base]"; exit 1; }
	$(call CHECK_NAME,VARIANT)
	$(call CHECK_NAME,TAILORED)
	$(call CHECK_NAME,FULLNAME)
	@test -f "$(VARIANT_TEX)" || { echo "Variant resume not found: $(VARIANT_TEX)"; exit 1; }
	@mkdir -p "$(TAILORED_DIR)"
	@test ! -e "$(TAILORED_TEX)" || { echo "Tailored resume already exists: $(TAILORED_TEX)"; exit 1; }
	cp "$(VARIANT_TEX)" "$(TAILORED_TEX)"

new-variant:
	@test -n "$(VARIANT)" || { echo "Usage: make new-variant VARIANT=name [FROM=base]"; exit 1; }
	$(call CHECK_NAME,VARIANT)
	$(call CHECK_NAME,FROM)
	@test "$(VARIANT)" != "$(FROM)" || { echo "VARIANT and FROM must be different"; exit 1; }
	@test -f "$(FROM_TEX)" || { echo "Source variant resume not found: $(FROM_TEX)"; exit 1; }
	@mkdir -p "$(VARIANT_DIR)"
	@test ! -e "$(VARIANT_TEX)" || { echo "Variant resume already exists: $(VARIANT_TEX)"; exit 1; }
	cp "$(FROM_TEX)" "$(VARIANT_TEX)"

preview: | $(BUILD_DIR)
	$(call CHECK_NAME,VARIANT)
	$(call CHECK_NAME,TAILORED)
	$(call CHECK_NAME,FULLNAME)
	$(CHECK_SOURCE)
	$(COMPILER) -pvc $(FLAGS) -jobname=$(OUTPUT_NAME) -outdir=$(BUILD_DIR) $(SOURCE)

export: | $(OUT_DIR)
	@test -n "$(TAILORED)" || { echo "Usage: make export TAILORED=name"; exit 1; }
	$(call CHECK_NAME,VARIANT)
	$(call CHECK_NAME,TAILORED)
	$(call CHECK_NAME,FULLNAME)
	$(MAKE) all TAILORED="$(TAILORED)" VARIANT="$(VARIANT)"
	cp "$(BUILD_DIR)/$(TAILORED_NAME).pdf" "$(OUT_DIR)/$(TAILORED_NAME).pdf"

clean:
	$(call CHECK_NAME,VARIANT)
	$(call CHECK_NAME,TAILORED)
	$(call CHECK_NAME,FULLNAME)
	$(CHECK_SOURCE)
	$(COMPILER) -C -jobname=$(OUTPUT_NAME) -outdir=$(BUILD_DIR) $(SOURCE)

cleanall:
	rm -rf $(BUILD_DIR)
	rm -rf $(OUT_DIR)

list:
	@printf "Variants:\n"
	@find "$(VARIANT_DIR)" -maxdepth 1 -name '*.tex' -exec basename {} .tex \; 2>/dev/null | sort
	@printf "\nTailored:\n"
	@find "$(TAILORED_DIR)" -maxdepth 1 -name '*.tex' -exec basename {} .tex \; 2>/dev/null | sort

help:
	@printf "\nUsage:\n"
	@printf "  make [target] [VARIANT=name] [TAILORED=name] [FROM=name] \n\n"
	@printf "Set FULLNAME once in the Makefile to prefix tailored resume files.\n\n"
	@printf "Names may contain only letters, numbers, underscores, and hyphens.\n\n"
	@printf "Examples:\n"
	@printf "  %-44s %s\n" "make" "Build build/base.pdf from variants/base.tex."
	@printf "  %-44s %s\n" "make VARIANT=cpp" "Build build/cpp.pdf from variants/cpp.tex."
	@printf "  %-44s %s\n" "make new-variant VARIANT=ios FROM=base" "Create variants/ios.tex from variants/base.tex."
	@printf "  %-44s %s\n" "make new TAILORED=company VARIANT=cpp" "Create a tailored resume from variants/cpp.tex."
	@printf "  %-44s %s\n" "make TAILORED=company" "Build the selected tailored resume PDF."
	@printf "  %-44s %s\n\n" "make export TAILORED=company" "Copy the selected tailored resume PDF to out/."
	@printf "Targets:\n"
	@printf "  %-12s %s\n" "all" "Build the selected variant or tailored resume."
	@printf "  %-12s %s\n" "new" "Create a new tailored resume from VARIANT."
	@printf "  %-12s %s\n" "new-variant" "Create a new reusable variant from FROM."
	@printf "  %-12s %s\n" "preview" "Continuously rebuild the selected output for preview."
	@printf "  %-12s %s\n" "export" "Copy the selected tailored resume PDF to out/."
	@printf "  %-12s %s\n" "clean" "Remove auxiliary and generated PDF files for the selected output."
	@printf "  %-12s %s\n" "cleanall" "Remove build and out directories."
	@printf "  %-12s %s\n" "list" "List available variants and tailored resumes."
	@printf "  %-12s %s\n\n" "help" "Show this help message."
