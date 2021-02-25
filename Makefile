#Standard Compiling Options
ARCH ?= i686
C := $(ARCH)-elf-gcc
CXX := $(ARCH)-elf-g++
AS := $(ARCH)-elf-gcc

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
ASSRCEXT := S

#Locate C and C++ files
CSOURCES := $(shell find $(SRCDIR) -type f -name "*.$(CSRCEXT)")
CPPSOURCES := $(shell find $(SRCDIR) -type f -name "*.$(CPPSRCEXT)")
#Get object files from C and C++ source files 
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(CSOURCES:.$(CSRCEXT)=.o)) $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(CPPSOURCES:.$(CPPSRCEXT)=.o))

#Get assembly source files and create objects from them 
ASSOURCES := $(shell find $(SRCDIR) -name global-$(ARCH) -prune -false -o -type f -name "*.$(ASSRCEXT)" -print)
ASOBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(ASSOURCES:.$(ASSRCEXT)=.o))

#Find dependencies from C and C++ source files
DEPENDENCIES := $(patsubst $(SRCDIR)/%,$(DEPDIR)/%,$(CSOURCES:.$(CSRCEXT)=.d))
DEPENDENCIES := $(DEPENDENCIES) $(patsubst $(SRCDIR)/%,$(DEPDIR)/%,$(CPPSOURCES:.$(CPPSRCEXT)=.d))


#Directories needed by gcc 
LIB := 
LIBDIR :=  
INC := -I include/ -I include/libc/ -I include/ACPICA

#Combined flags (Both C and C++)
FLAGS := -O2 -Wall -Wextra -g -D__is_kernel -ffreestanding -fstack-protector
#Specific flags
CFLAGS := $(FLAGS) -std=gnu99 
CXXFLAGS := $(FLAGS) -std=c++17
ASFLAGS := -c -g -gdwarf-5 

#Make sure certain directories are made
$(shell mkdir -p $(BUILDDIR) $(DEPDIR) bin/)

#Copy the tree structure of src/ to the build/ and dep/ directories
TREE := $(shell find $(SRCDIR) -type d)
$(shell mkdir -p $(patsubst $(SRCDIR)/%, $(BUILDDIR)/%, $(TREE)))
$(shell mkdir -p $(patsubst $(SRCDIR)/%, $(DEPDIR)/%, $(TREE)))

GLOBALARCHDIR	:= $(BUILDDIR)/arch/global-$(ARCH)

#Define/create the global constructor objects
CRTBEGINOBJ := $(shell $(C) $(CFLAGS) -print-file-name=crtbegin.o)
CRTENDOBJ := $(shell $(C) $(CFLAGS) -print-file-name=crtend.o)

CRTBEGIN := $(GLOBALARCHDIR)/crti.o $(CRTBEGINOBJ)
CRTEND := $(CRTENDOBJ) $(GLOBALARCHDIR)/crtn.o

LINKERFILE := $(SRCDIR)/linker.lds

MAKEOBJS := $(GLOBALARCHDIR)/crti.o $(GLOBALARCHDIR)/crtn.o $(BUILDDIR)/linker.lds $(OBJECTS) $(ASOBJECTS)

#Order the objects to prevent weird gcc bugs with global constructors
MAINOBJS := $(CRTBEGIN) $(OBJECTS) $(ASOBJECTS) $(CRTEND)

#Compile Target
bin/ZoarialBareOS.iso: bin/ZoarialBareOS.bin bin/grub.cfg
	grub2-file --is-x86-multiboot bin/ZoarialBareOS.bin
	mkdir -p $(BUILDDIR)/isodir/boot/grub
	cp bin/ZoarialBareOS.bin $(BUILDDIR)/isodir/boot/
	cp $(SRCDIR)/grub.cfg $(BUILDDIR)/isodir/boot/grub/grub.cfg
	grub2-mkrescue -o $@ $(BUILDDIR)/isodir

bin/ZoarialBareOS.bin: $(MAKEOBJS) 
	@echo " Linking... $(MAINOBJS)"
	$(C) -T build/linker.lds $(MAINOBJS) -o $@ -ffreestanding -O2 -nostdlib -lgcc

bin/grub.cfg: $(SRCDIR)/grub.cfg
	cp $(SRCDIR)/grub.cfg bin/grub.cfg

$(BUILDDIR)/linker.lds: $(LINKERFILE)
	$(C) $(CFLAGS) $(INC) -E -P -o $@ -x c-header $^

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
	$(AS) $(ASFLAGS) $(INC) -o $@ $<

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
