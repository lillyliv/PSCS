# PSCS
Peoples Secure Computing System is a free operating system for the people, by the people for x86 Intel/AMD compatible systems. It runs in 16 bit real mode (80386 and higher required for 4GB memory, however). PSCS boots from floppy or bios emulated floppy (happens automatically) and supports vga text and graphics.

## Build Dependencies

PSCS only requires an up to date version of NASM to build and qemu-system-x86_64 to run. Currently the binary takes up one 1.44 mb floppy for the os and another 1.44 mb floppy for the data disk

## Future plans

I want PSCS to turn into PSCSC (Peoples secure computing system client) which runs on very weak machines and stores its files and memory on a central server (PSCSS) with the last S being for server and the PSCS project becoming both of them in one repo as they will rely heavily on eachother.

In the nearer future, however, I would like to make a text editor ( in progress ) and an assembler after I finish the text editor.

after both of these things I would like to port PSCSS and PSCSC to Raspberry Pi and PowerPC.
