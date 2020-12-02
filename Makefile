#Standard Compiling Options
CXX := i686-elf-gcc
AS := i686-elf-as
SRCDIR := src
BUILDDIR := build
INCDIR := include
TARGET := bin/ZoarialBareOS.iso
DEPDIR := dep

#Testing Compiling Options
TESTSRCDIR := tests
TESTBUILDDUR := tests/build
TESTTARGET := bin/test

#Standard Compiling Files and Arguments
CSRCEXT := c
CINCEXT := h
ASSRCEXT := s

CSOURCES := $(shell find $(SRCDIR) -type f -name "*.$(CSRCEXT)")
COBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(CSOURCES:.$(CSRCEXT)=.o))

ASSOURCES := $(shell find $(SRCDIR) -type f -name "*.$(ASSRCEXT)")
ASOBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(ASSOURCES:.$(ASSRCEXT)=.o))

DEPENDENCIES := $(patsubst $(SRCDIR)/%,$(DEPDIR)/%,$(CSOURCES:.$(CSRCEXT)=.d))
LIB := 
LIBDIR :=  
CXXFLAGS := -std=gnu99 -ffreestanding -O2 -Wall -Wextra
ASFLAGS := 
INC := -I include

#Testing Compiling Files and Arguments
#TESTSOURCES := $(shell find $(TESTSRCDIR) -type f -name "*.$(SRCEXT)")
#TESTOBJECTS := $(patsubst $(TESTSRCDIR)/%,$(TESTBUILDDIR)/%,$(TESTSOURCES:.$(SRCEXT)=.o))

MAINOBJS := $(COBJECTS) $(ASOBJECTS)
EXAMOBJS := $(OBJECTS) $(BUILDDIR)/example.o


#Compile Target
bin/ZoarialBareOS.iso: bin/ZoarialBareOS.bin bin/grub.cfg
	grub2-mkrescue -o myos.iso isodir

bin/ZoarialBareOS.bin: $(MAINOBJS)
	@echo " Linking... $(MAINOBJS)"
	$(CXX) -T $(SRCDIR)/linker.ld $^ -o $@ -ffreestanding -O2 -nostdlib -lgcc
	grub2-file --is-x86-multiboot $@
	cp $@ $(BUILDDIR)/isodir/boot/


bin/grub.cfg: $(SRCDIR)/grub.cfg
	cp $(SRCDIR)/grub.cfg bin/grub.cfg

#Include dependencies which are created
#-include $(DEPENDENCIES:)
include $(wildcard $(DEPENDENCIES))

#Create object files
$(BUILDDIR)/%.o: $(SRCDIR)/%.$(CSRCEXT)
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
	@rm -f $(DEPDIR)/$*.d.tm

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
	$(RM) -r $(BUILDDIR) $(DEPDIR) $(TARGET)

.PHONY: clean

#Basic example
Example: $(EXAMOBJS)
	



#Prevents failure if dependency does not exist
$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d
