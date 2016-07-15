BUILD ?= $(PWD)/build
EXENAME := $(BUILD)/rpg
SRCFILES := $(wildcard *.cpp)
OBJECTS := $(patsubst %.cpp,$(BUILD)/%.o,$(SRCFILES))

# `all` is not a real file
.PHONY: all

# build the binary by default
all: $(EXENAME)

# JsonBox {{{

JSONBOX_SRC := $(PWD)/JsonBox
JSONBOX_BUILD := $(BUILD)/JsonBox
JSONBOX_BIN := $(JSONBOX_BUILD)/libJsonBox.a

CXXFLAGS += -I$(JSONBOX_SRC)/include -I$(JSONBOX_BUILD)
LDFLAGS += -L$(JSONBOX_BUILD) -lJsonBox

# force rebuilding each time
.PHONY: $(JSONBOX_BIN)

$(JSONBOX_BIN):
	mkdir -p $(JSONBOX_BUILD)
	cd $(JSONBOX_BUILD) && cmake $(JSONBOX_SRC)
	make -C $(JSONBOX_BUILD)

# }}}

# source code compilation {{{

# compile *.cpp source files into *.o object files
$(BUILD)/%.o: %.cpp
	$(CXX) -c $(CXXFLAGS) $^ -o $@

# build the binary, link to JsonBox
$(EXENAME): $(OBJECTS) $(JSONBOX_BIN)
	$(CXX) $(LDFLAGS) $^ -o $@

# }}}

# utility recipes {{{

# `clean` is not a real file
.PHONY: clean

# clean the build directory
clean:
	rm -rf $(BUILD)

# }}}