vpath %.s arm aarch64
debugfile=dbgfile

default:
	@echo "please input a target"

a64prefix := aarch64-linux-gnu
ARMTOOL := $(shell which arm-none-eabi-gcc)
A64TOOL := $(shell which $(a64prefix)-gcc)


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
	@if [ "$(A64TOOL)" == "" ]; then \
		echo "Please install gcc for aarch64."; \
	else \
		cd `dirname $(A64TOOL)`; \
		sudo ln -sf $(a64prefix)-gcc aagcc; \
		sudo ln -sf $(a64prefix)-as aaas; \
		sudo ln -sf $(a64prefix)-objcopy aaobjcopy; \
		sudo ln -sf $(a64prefix)-ld aald; \
	fi
	
%: %.s
	@if [ -f arm/$@.s ]; then \
		gccarm=agcc; objcpyarm=aobjcopy; ipath=arm; \
	elif [ -f aarch64/$@.s ]; then \
		gccarm=aagcc; objcpyarm=aaobjcopy; ipath=aarch64; \
	fi; \
	$$gccarm -Wl,-Ttext=0 -o $(debugfile).elf $$ipath/$@.s -g -nostdlib; \
	$$objcpyarm -O binary $(debugfile).elf $(debugfile).bin

qemu-pre:
	dd if=/dev/zero of=flash.bin bs=4096 count=4096
	dd if=$(debugfile).bin of=flash.bin bs=4096 conv=notrunc

qemu-arm: qemu-pre
	qemu-system-arm -M connex -pflash flash.bin -nographic -serial /dev/null -S -s

qemu-aa64: qemu-pre
	qemu-system-aarch64 -cpu cortex-a57 -M connex -pflash flash.bin -nographic -serial /dev/null -S -s

gdb:
	cgdb -d agdb ./$(debugfile).elf -ex "target remote localhost:1234"

.PHONY: clean
clean:
	-rm -rf *.bin *.elf

.DEFAULT:
	@echo This target is not exist.
