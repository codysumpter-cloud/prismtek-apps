TARGET := tamernet_battle_sandbox_ds
BUILD := build
SOURCES := source
DATA := data
INCLUDES :=

include $(DEVKITARM)/ds_rules

CFILES := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
OFILES := $(CFILES:.c=.o)

ARCH := -mthumb -mthumb-interwork
CFLAGS := -g -Wall -O2 $(ARCH) $(INCLUDE) -DARM9
LDFLAGS := -specs=ds_arm9.specs -g $(ARCH) -Wl,-Map,$(notdir $*.map)
LIBS := -lnds9

.PHONY: all clean

all: $(TARGET).nds

$(TARGET).nds: $(TARGET).elf
	ndstool -c $@ -9 $(TARGET).elf

$(TARGET).elf: $(OFILES)
	$(CC) $(LDFLAGS) $(OFILES) $(LIBS) -o $@

%.o: $(SOURCES)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OFILES) $(TARGET).elf $(TARGET).nds $(TARGET).map
