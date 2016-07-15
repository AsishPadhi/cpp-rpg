SRC := $(PWD)/src
BUILD ?= $(PWD)/build
EXENAME ?= $(BUILD)/rpg
SRCFILES := $(wildcard $(SRC)/*.cpp)
OBJECTS := $(patsubst $(SRC)/%.cpp,$(BUILD)/%.o,$(SRCFILES))

.PHONY: all

# build the executable by default
all: $(EXENAME)
-include $(OBJECTS:.o=.d)

# JsonBox {{{

JSONBOX_SRC := $(PWD)/JsonBox
JSONBOX_BUILD := $(BUILD)/JsonBox
JSONBOX_BIN := $(JSONBOX_BUILD)/libJsonBox.a

CXXFLAGS += -std=c++11 -I$(JSONBOX_SRC)/include -I$(JSONBOX_BUILD)
LDFLAGS += -L$(JSONBOX_BUILD) -lJsonBox

$(JSONBOX_BIN): $(wildcard $(JSONBOX_SRC)/include/JsonBox.h) \
				$(wildcard $(JSONBOX_SRC)/include/JsonBox/*.h) \
				$(wildcard $(JSONBOX_SRC)/src/*.cpp)
	@mkdir -p $(JSONBOX_BUILD)
	cd $(JSONBOX_BUILD) && cmake $(JSONBOX_SRC)
	$(MAKE) -C $(JSONBOX_BUILD) JsonBox

# we rely on build/JsonBox/Export.h, build libJsonBox.a to make this file exist
$(OBJECTS): $(JSONBOX_BIN)

# }}}

# source code compilation {{{

-include $(OBJECTS:.o=.d)

# src/*.cpp -> build/*.o
$(BUILD)/%.o: $(SRC)/%.cpp
	@mkdir -p $(BUILD)
	$(CXX) -MMD -c $(CXXFLAGS) $< -o $@

# build/*.o + libJsonBox.a -> build/rpg (executable)
# NOTE: build/*.o already depends on libJsonBox.a
$(EXENAME): $(OBJECTS)
	$(CXX) $^ -o $@ $(LDFLAGS)

# }}}

# utility recipes {{{

.PHONY: clean

# clean the build directory
clean:
	rm -rf $(BUILD)

# }}}