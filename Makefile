.PHONY: all kernel

KERNEL_VERSION:=4.5
KERNELDIR:=kernel/linux-${KERNEL_VERSION}
MAKE_ENV:=ARCH=arm
LOADADDR:=0x80008000

MTK_EVB_DTB:=mt7623-evb.dtb
MTK_NVR_DTB:=mt7623-nvr.dtb

#all: evb.bin nvr.bin
all: nvr.bin

${KERNELDIR}/.config:
	cp -f configs/config-${KERNEL_VERSION} $@
	env $(MAKE_ENV) $(MAKE) -C ${KERNELDIR} oldconfig

kernel: ${KERNELDIR}/.config
	env $(MAKE_ENV) $(MAKE) -C ${KERNELDIR} zImage

.evb.zImage: kernel
	env $(MAKE_ENV) $(MAKE) -C ${KERNELDIR} $(MTK_EVB_DTB)
	cat ${KERNELDIR}/arch/arm/boot/zImage ${KERNELDIR}/arch/arm/boot/dts/${MTK_EVB_DTB} > $@

evb.bin: .evb.zImage
	mkimage \
		-A arm -O linux -T kernel \
		-n "mt7623 Linux (ubnt)" \
		-C none \
		-a ${LOADADDR} -e ${LOADADDR} \
		-d $< \
		$@

.nvr.zImage: kernel
	env $(MAKE_ENV) $(MAKE) -C ${KERNELDIR} $(MTK_NVR_DTB)
	cat ${KERNELDIR}/arch/arm/boot/zImage ${KERNELDIR}/arch/arm/boot/dts/${MTK_NVR_DTB} > $@

nvr.bin: .nvr.zImage
	mkimage \
		-A arm -O linux -T kernel \
		-n "mt7623 Linux (ubnt)" \
		-C none \
		-a ${LOADADDR} -e ${LOADADDR} \
		-d $< \
		$@

