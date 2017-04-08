## Makefile

.PHONY: clean realclean

CC=clang++

OUTNAME_BIN=minidock
BUILDDIR_BIN=bin
OBJDIR=obj

INCDIR=

SRCDIR=src
SRCDIR_HDRS=src

LIBS=-lcurl
LIBDIR=
LDFLAGS=-framework Carbon -framework Cocoa -framework CoreAudio

CPPFLAGS=-Wall -std=c++14
OPTFLAGS=-m64 -O3 -flto -march=native

#########################################################################################

INCLUDES+=$(patsubst %,-I%,$(INCDIR))
LDFLAGS+=$(patsubst %,-L%,$(LIBDIR))

CPPFLAGS+=$(OPTFLAGS)
LDFLAGS+=$(OPTFLAGS)

# SRCDIR files
HDRS=$(wildcard $(SRCDIR_HDRS)/**/**/*.h)
HDRS=$(wildcard $(SRCDIR_HDRS)/**/*.h)
HDRS+=$(wildcard $(SRCDIR_HDRS)/*.h)
HDRS+=$(wildcard $(SRCDIR_HDRS)/**/**/*.hxx)
HDRS+=$(wildcard $(SRCDIR_HDRS)/**/*.hxx)
HDRS+=$(wildcard $(SRCDIR_HDRS)/*.hxx)
OBJS+=$(patsubst $(SRCDIR)/%.cc,$(OBJDIR)/%.o, $(wildcard $(SRCDIR)/**/**/*.cc))
OBJS+=$(patsubst $(SRCDIR)/%.cc,$(OBJDIR)/%.o, $(wildcard $(SRCDIR)/**/*.cc))
OBJS+=$(patsubst $(SRCDIR)/%.cc,$(OBJDIR)/%.o, $(wildcard $(SRCDIR)/*.cc))
OBJS+=$(patsubst $(SRCDIR)/%.mm,$(OBJDIR)/%.o, $(wildcard $(SRCDIR)/**/**/*.mm))
OBJS+=$(patsubst $(SRCDIR)/%.mm,$(OBJDIR)/%.o, $(wildcard $(SRCDIR)/**/*.mm))
OBJS+=$(patsubst $(SRCDIR)/%.mm,$(OBJDIR)/%.o, $(wildcard $(SRCDIR)/*.mm))

TARGET_BIN=$(BUILDDIR_BIN)/$(OUTNAME_BIN)


all: realclean $(TARGET_BIN)

$(TARGET_BIN):$(OBJS) 
	@mkdir -p $(@D)
	$(CC) -o $(TARGET_BIN)    $(LDFLAGS) $(OBJS) $(LIBS)

# dependencies
$(OBJDIR)/%.o:$(SRCDIR)/%.cc $(HDRS)
	@mkdir -p $(@D)
	$(CC) -o $@    $(CPPFLAGS) $(INCLUDES) -c $<

$(OBJDIR)/%.o:$(SRCDIR)/%.mm $(HDRS)
	@mkdir -p $(@D)
	$(CC) -o $@    $(CPPFLAGS) $(INCLUDES) -c $<

## other options
clean:
	rm -rf $(OBJS)

realclean:
	rm -rf $(OBJDIR) $(TARGET_BIN) 

