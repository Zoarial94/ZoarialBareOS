#Standard Compiling Options

#Something weird with i386 vs i686
ARCH ?= i386
C := i686-elf-gcc
CXX := i686-elf-g++
AS := i686-elf-as

#Separate out source directories for better compartmentalization
SRCDIR 			:= src
ARCHDIR 		:= $(SRCDIR)/arch/$(ARCH) 
LIBCDIR 		:= $(SRCDIR)/libc
KERNELDIR 		:= $(SRCDIR)/kernel
SRCDIRS 		:= $(ARCHDIR) $(LIBCDIR) $(KERNELDIR)

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

#Locate C and C++ files
CSOURCES := $(shell find $(SRCDIRS) -type f -name "*.$(CSRCEXT)")
CPPSOURCES := $(shell find $(SRCDIRS) -type f -name "*.$(CPPSRCEXT)")
#Get object files from C and C++ source files 
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(CSOURCES:.$(CSRCEXT)=.o)) $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(CPPSOURCES:.$(CPPSRCEXT)=.o))

#Get assembly source files and create objects from them 
ASSOURCES := $(shell find $(SRCDIRS) -type f -name "*.$(ASSRCEXT)")
ASOBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(ASSOURCES:.$(ASSRCEXT)=.o))

#Find dependencies from C and C++ source files
DEPENDENCIES := $(patsubst $(SRCDIR)/%,$(DEPDIR)/%,$(CSOURCES:.$(CSRCEXT)=.d))
DEPENDENCIES := $(DEPENDENCIES) $(patsubst $(SRCDIR)/%,$(DEPDIR)/%,$(CPPSOURCES:.$(CPPSRCEXT)=.d))


#Directories needed by gcc 
LIB := 
LIBDIR :=  
INC := -I include/ -I include/libc/

#Combined flags (Both C and C++)
FLAGS := -O2 -Wall -Wextra -g -D__is_kernel -ffreestanding
#Specific flags
CFLAGS := $(FLAGS) -std=gnu99 
CXXFLAGS := $(FLAGS) -std=c++17
ASFLAGS := 

#Make sure certain directories are made
$(shell mkdir -p $(BUILDDIR) $(DEPDIR) bin/)

#Copy the tree structure of src/ to the build/ and dep/ directories
TREE := $(shell find $(SRCDIR) -type d)
$(shell mkdir -p $(patsubst $(SRCDIR)/%, $(BUILDDIR)/%, $(TREE)))
$(shell mkdir -p $(patsubst $(SRCDIR)/%, $(DEPDIR)/%, $(TREE)))

GLOBALARCHDIR	:= $(BUILDDIR)/arch/global-$(ARCH)

#Define/create the global constructor objects
CRTBEGINOBJ := $($(C) $(CFLAGS) -print-file-name=crtbegin.o)
CRTENDOBJ := $($(C) $(CFLAGS) -print-file-name=crtend.o)

CRTBEGIN := $(GLOBALARCHDIR)/crti.o $(GLOBALARCHDIR)/crtbegin.o
CRTEND := $(GLOBALARCHDIR)/crtend.o $(GLOBALARCHDIR)/crtn.o

#Order the objects to prevent weird gcc bugs with global constructors
MAINOBJS := $(CRTBEGIN) $(OBJECTS) $(ASOBJECTS) $(CRTEND)

#Compile Target
bin/ZoarialBareOS.iso: bin/ZoarialBareOS.bin bin/grub.cfg
	cp bin/ZoarialBareOS.bin $(BUILDDIR)/isodir/boot/
	cp $(SRCDIR)/grub.cfg $(BUILDDIR)/isodir/boot/grub/grub.cfg
	grub2-mkrescue -o $@ $(BUILDDIR)/isodir

bin/ZoarialBareOS.bin: $(MAINOBJS)
	@echo " Linking... $(MAINOBJS)"
	$(C) -T $(SRCDIR)/linker.ld $^ -o $@ -ffreestanding -O2 -nostdlib -lgcc
	grub2-file --is-x86-multiboot $@
	mkdir -p $(BUILDDIR)/isodir/boot/grub


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

$(GLOBALARCHDIR)/crtbegin.o $(GLOBALARCHDIR)/crtend.o:
	OBJ=`$(C) $(CFLAGS) -print-file-name=$(@F)` && cp "$$OBJ" $@



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
