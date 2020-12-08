#Standard Compiling Options
ARCH ?= i386
C := i686-elf-gcc
CXX := i686-elf-g++
AS := i686-elf-as
SRCDIR := src
SRCDIRS := src/arch/$(ARCH) src/kernel
BUILDDIR := build
INCDIR := include
TARGET := bin/ZoarialBareOS.iso
DEPDIR := dep

#Standard Compiling Files and Arguments
CSRCEXT := c
CINCEXT := h
CPPSRCEXT := cpp
CPPINCEXT := hpp
ASSRCEXT := s

CSOURCES := $(shell find $(SRCDIRS) -type f -name "*.$(CSRCEXT)")
CPPSOURCES := $(shell find $(SRCDIRS) -type f -name "*.$(CPPSRCEXT)")
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(CSOURCES:.$(CSRCEXT)=.o)) $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(CPPSOURCES:.$(CPPSRCEXT)=.o))

#$(info OBJECTS is $(OBJECTS))

ASSOURCES := $(shell find $(SRCDIRS) -type f -name "*.$(ASSRCEXT)")
ASOBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(ASSOURCES:.$(ASSRCEXT)=.o))

DEPENDENCIES := $(patsubst $(SRCDIR)/%,$(DEPDIR)/%,$(CSOURCES:.$(CSRCEXT)=.d))
DEPENDENCIES := $(DEPENDENCIES) $(patsubst $(SRCDIR)/%,$(DEPDIR)/%,$(CPPSOURCES:.$(CPPSRCEXT)=.d))

LIB := 
LIBDIR :=  
FLAGS := -O2 -Wall -Wextra -g
CFLAGS := $(FLAGS) -std=gnu99 -ffreestanding
CXXFLAGS := $(FLAGS) -std=c++17
ASFLAGS := 
INC := -I include/ -I include/libc/

#Testing Compiling Files and Arguments
#TESTSOURCES := $(shell find $(TESTSRCDIR) -type f -name "*.$(SRCEXT)")
#TESTOBJECTS := $(patsubst $(TESTSRCDIR)/%,$(TESTBUILDDIR)/%,$(TESTSOURCES:.$(SRCEXT)=.o))

MAINOBJS := $(OBJECTS) $(ASOBJECTS)

$(shell mkdir -p $(BUILDDIR) $(DEPDIR) bin/)

TREE := $(shell find $(SRCDIR) -type d)

$(shell mkdir -p $(patsubst $(SRCDIR)/%, $(BUILDDIR)/%, $(TREE)))
$(shell mkdir -p $(patsubst $(SRCDIR)/%, $(DEPDIR)/%, $(TREE)))

#Compile Target
bin/ZoarialBareOS.iso: bin/ZoarialBareOS.bin bin/grub.cfg
	grub2-mkrescue -o $@ $(BUILDDIR)/isodir

bin/ZoarialBareOS.bin: $(MAINOBJS)
	@echo " Linking... $(MAINOBJS)"
	$(CXX) -T $(SRCDIR)/linker.ld $^ -o $@ -ffreestanding -O2 -nostdlib -lgcc
	grub2-file --is-x86-multiboot $@
	mkdir -p $(BUILDDIR)/isodir/boot/
	cp $@ $(BUILDDIR)/isodir/boot/


bin/grub.cfg: $(SRCDIR)/grub.cfg
	cp $(SRCDIR)/grub.cfg bin/grub.cfg

#Include dependencies which are created
#-include $(DEPENDENCIES:)
include $(wildcard $(DEPENDENCIES))

#Create C++ object files
$(BUILDDIR)/%.o: $(SRCDIR)/%.$(CPPSRCEXT)
#Make build directory
	@mkdir -p $(BUILDDIR)
	@mkdir -p $(DEPDIR)
#Make Makefiles
	$(CXX) $(CXXFLAGS) $(INC) -MT $@ -MM -MP $< > $(DEPDIR)/$*.Td
	@cd $(DEPDIR); \
	cp $*.Td $*.d; \
    sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	-e '/^$$/ d' -e 's/$$/ :/' < $*.Td >> $*.d; \
	rm -f $*.Td; \
	cd ../;
#Compile object
	$(CXX) $(CXXFLAGS) $(INC) -c -o $@ $<
#Fancy deleting/copying
#Handles files that no longer exist
	@cp -f $(DEPDIR)/$*.d $(DEPDIR)/$*.d.tmp
	@sed -e 's/.*://' -e 's/\\$$//' < $(DEPDIR)/$*.d.tmp | fmt -1 | \
	sed -e 's/^ *//' -e 's/$$/:/' >> $(DEPDIR)/$*.d
	@rm -f $(DEPDIR)/$*.d.tmp
		
#Create C object files
$(BUILDDIR)/%.o: $(SRCDIR)/%.$(CSRCEXT)
#Make build directory
	@mkdir -p $(BUILDDIR)
	@mkdir -p $(DEPDIR)
#Make Makefiles
	$(C) $(CFLAGS) $(INC) -MT $@ -MM -MP $< > $(DEPDIR)/$*.Td
	@cd $(DEPDIR); \
	cp $*.Td $*.d; \
    sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	-e '/^$$/ d' -e 's/$$/ :/' < $*.Td >> $*.d; \
	rm -f $*.Td; \
	cd ../;
#Compile object
	$(C) $(CFLAGS) $(INC) -c -o $@ $<
#Fancy deleting/copying
#Handles files that no longer exist
	@cp -f $(DEPDIR)/$*.d $(DEPDIR)/$*.d.tmp
	@sed -e 's/.*://' -e 's/\\$$//' < $(DEPDIR)/$*.d.tmp | fmt -1 | \
	sed -e 's/^ *//' -e 's/$$/:/' >> $(DEPDIR)/$*.d
	@rm -f $(DEPDIR)/$*.d.tmp

#Create object files
$(BUILDDIR)/%.o: $(SRCDIR)/%.$(ASSRCEXT)
#Make build directory
	@mkdir -p $(BUILDDIR)
	@mkdir -p $(DEPDIR)
#Compile object
	$(AS) $(ASFLAGS) -o $@ $<

#Clean
clean:
	@echo " Cleaning..."; 
	$(RM) -r $(BUILDDIR) $(DEPDIR) bin/

.PHONY: clean

#Basic example
Example: $(EXAMOBJS)
	



#Prevents failure if dependency does not exist
$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d
