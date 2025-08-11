CXX = g++
CXXFLAGS = -O2 -std=c++11 -Iinclude -IKeyFinderLib

ifeq ($(OS),Windows_NT)
    # Windows
    LDFLAGS = -L"AMD_APP_SDK/2.9-1/lib/x86_64" -lOpenCL -lbcrypt
else
    # Linux
    LDFLAGS = -lOpenCL
endif

# Directories
SRCDIR = src
BUILDDIR = build
BINDIR = bin

CORE_SOURCES = $(wildcard $(SRCDIR)/core/*.cpp)
OPENCL_SOURCES = $(wildcard $(SRCDIR)/opencl/*.cpp) $(SRCDIR)/bitcrack_cl.cpp
MAIN_SOURCES = $(filter-out %_backup.cpp, $(wildcard $(SRCDIR)/main/*.cpp))
EMBEDCL_SOURCES = $(SRCDIR)/embedcl.cpp

CORE_OBJS = $(CORE_SOURCES:$(SRCDIR)/%.cpp=$(BUILDDIR)/%.o)
OPENCL_OBJS = $(OPENCL_SOURCES:$(SRCDIR)/%.cpp=$(BUILDDIR)/%.o)
MAIN_OBJS = $(MAIN_SOURCES:$(SRCDIR)/%.cpp=$(BUILDDIR)/%.o)
EMBEDCL_OBJS = $(BUILDDIR)/embedcl.o

TARGETS = $(BINDIR)/bitcrack $(BINDIR)/embedcl

.PHONY: all clean

all: $(TARGETS)

$(BINDIR)/embedcl: $(EMBEDCL_OBJS)
	@mkdir -p $(BINDIR)
	$(CXX) $(EMBEDCL_OBJS) -o $@

$(BINDIR)/bitcrack: $(CORE_OBJS) $(OPENCL_OBJS) $(MAIN_OBJS)
	@mkdir -p $(BINDIR)
	$(CXX) $^ $(LDFLAGS) -o $@

$(BUILDDIR)/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILDDIR)/embedcl.o: $(EMBEDCL_SOURCES)
	@mkdir -p $(BUILDDIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILDDIR) $(BINDIR)

$(BUILDDIR)/kernels: $(wildcard $(SRCDIR)/*.cl)
	@mkdir -p $(BUILDDIR)
	cp $(SRCDIR)/*.cl $(BUILDDIR)/

$(CORE_OBJS): $(BUILDDIR)/kernels
$(OPENCL_OBJS): $(BUILDDIR)/kernels
$(MAIN_OBJS): $(BUILDDIR)/kernels
