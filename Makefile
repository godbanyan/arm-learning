debugfile=main
dirdiv=directives

VPATH=$(dirdiv)

default:
	@echo "please input a target"

ARMTOOL := $(shell which arm-none-eabi-gcc)

install:
	@if [ "$(ARMTOOL)" == "" ]; then \
		echo "Please install gcc for arm."; \
	else \
		cd `dirname $(ARMTOOL)`; \
		sudo ln -sf arm-none-eabi-gcc agcc; \
		sudo ln -sf arm-none-eabi-gdb agdb; \
		sudo ln -sf arm-none-eabi-as aas; \
		sudo ln -sf arm-none-eabi-objcopy aobjcopy; \
		sudo ln -sf arm-none-eabi-ld ald; \
	fi

%: %.s
	agcc -Wl,-Ttext=0 -o $(debugfile).elf $(dirdiv)/$@.s -g -nostdlib
	aobjcopy -O binary $(debugfile).elf $(debugfile).bin

qemu-pre:
	dd if=/dev/zero of=flash.bin bs=4096 count=4096
	dd if=$(debugfile).bin of=flash.bin bs=4096 conv=notrunc

qemu: qemu-pre
	qemu-system-arm -M connex -pflash flash.bin -nographic -serial /dev/null -S -s

gdb:
	cgdb -d agdb ./$(debugfile).elf -ex "target remote localhost:1234"

.PHONY: clean
clean:
	-rm *.bin *.elf
