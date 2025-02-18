# Andes OpenWrt

## How to Build

To build an SD card image, first obtain all the latest package definitions and install symlinks for these packages:

        $ ./scripts/feeds update -a
        $ ./scripts/feeds install -a

Next, configure the target system and the toolchain as shown below to align with the package in AndeSight™ v5.4.0:

1. Configure the target system

        Target System (Andes AE350-AX45MP platform)

2. Configure the GCC compiler version

        [*] Advanced configuration options ---->
                [*]   Toolchain Options  --->
                        GCC compiler Version (gcc 14.x)

Finally, run `make` to build your firmware.

## Build Results

Upon completion of the build process, you will get below files:

| File                            | Description                                                                                      |
|---------------------------------|--------------------------------------------------------------------------------------------------|
| `openwrt-ae350-generic-ae350_rv64_spl_xip-ext4-sdcard.img.gz` | A compressed image which will be written onto the SD card. If you decompress it, there are two partitions for this image. The first partition contains `ax45mp_c4_d_dsp_ae350.dtb`, `boot.scr`, `Image`, `u-boot-spl.bin`, and `u-boot.itb`. The second partition is the root file system.
| `ax45mp_c4_d_dsp_ae350.dtb`     | Device Tree Blob. The naming convention is structured as follows: `<cpu>_c<core-count>_<double-float-support>_<andes-dsp-support>_<platform>.dtb`. It will be programmed onto flash memory using `SPI_burn` tool. |
| `boot.scr`                 | It is a compiled U-Boot script that contains boot commands for automatically configuring and booting an embedded system. |
| `Image`                    | A Flat Kernel Image that is bootable with `booti` in U-Boot.
| `u-boot-spl.bin`                | The Secondary Program Loader (SPL) of U-Boot which will be programmed onto flash memory using `SPI_burn` tool. |
| `u-boot.itb`                    | A FIT (Flattened Image Tree) format bootloader image used in U-Boot. It combines OpenSBI (fw_dynamic.bin) and will be loaded by U-Boot SPL. It will be programmed onto flash memory using `SPI_burn` tool.|

## Updating U-Boot SPL, U-Boot ITB and Device Tree on Flash

To update the bootloader, use the [SPI_burn](https://github.com/andestech/Andes-Development-Kit) tool.
Ensure you have an ICEman connection set up as follows:

```
  Local Host                 Local/Remote Host
 .----------------.          .--------------.
 | yocto images   |          |              |
 |                |         ICEman host <IP:PORT>
 | .----------.   |          |  .--------.  |
 | | SPI_burn |<--+--socket--+->| ICEman |  |
 | '----------'   |          |  '--.-----'  |
 '----------------'          '-----|--------'
                                   |
                                   USB
   .--------------.                |
   | target       |          .-----v-----.
   | board        <---JTAG---| ICE       |
   |              |          '-----------'
   '--------------'
```

> You can download the [pre-built SPI_burn](https://github.com/andestech/meta-andes/raw/ast-v5_3_0-branch/tools/SPI_burn) for x86 hosts and skip building it locally from source.

Download & extract `SPI_burn` source code:

```
$ wget https://github.com/andestech/Andes-Development-Kit/releases/download/ast-v5_3_0-release-windows/flash.zip
$ unzip flash.zip
$ cd ./flash/src-SPI_burn
```

Build `SPI_burn`:

```
$ ./build_SPIburn.sh
```

Program the U-Boot SPL & ITB and device-tree blob onto flash memory:

```
$ ICE_HOST=<ICEman host IP>
$ ICE_PORT=<ICEman host burner port>
$ ./SPI_burn --host $ICE_HOST --port $ICE_PORT --addr 0x0 -i u-boot-spl.bin
$ ./SPI_burn --host $ICE_HOST --port $ICE_PORT --addr 0x40000 -i u-boot.itb
$ ./SPI_burn --host $ICE_HOST --port $ICE_PORT --addr 0x1E0000 -i ae350.dtb
```

## Flashing Image to SD Card

Use the Linux `dd` command to flash the image to an SD card.

```
$ gunzip -c <IMAGE>.wic.gz | sudo dd of=/dev/sdX bs=4M iflag=fullblock oflag=direct conv=fsync status=progress
$ sync
```

Or you can use the [balenaEther](https://www.balena.io/etcher/) to flash the image on Windows and macOS.

<img src="https://i.imgur.com/W7YZc8j.png" width="450px" />

Upon inserting the SD card, access the serial console (e.g. [`picocom`](https://linux.die.net/man/8/picocom)) with the baud rate settings `115200/8-N-1`, and then reset the board. The system should start the boot process.

```
$ sudo picocom -b 115200 /dev/ttyUSB1
```

### RISC-V Boot Process

Andes platforms follow the typical RISC-V boot process illustrated below.

```
                       .-------------------------.
                       | (u-boot.itb)            |
                       |                         |
(1)-----------------+  | (2)-----------------+   |
 |  U-Boot SPL      |--+->|  OpenSBI         |   |
 | (u-boot-spl.bin) |  |  | (fw_dynamic.bin) |   |
 +------------------+  |  +---------.--------+   |
                       |            |            |
Machine mode           |            |            |
.......................|............|............|..................
Supervisor mode        |            |            |
                       |            v            |
                       | (3)-------------------+ |   (4)-----------+
                       |  |  U-Boot            |-+--->|  Linux     |
                       |  | (u-boot-nodtb.bin) | |    | (Image)    |
                       |  +--------------------+ |    +------------+
                       '-------------------------'
```