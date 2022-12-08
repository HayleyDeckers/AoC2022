## Advent of Code 2022, on a bare-metal raspberrypi-4, with only assembly.

> Why?

¯\\\_(ツ)\_/¯ I was already playing around with bare-metal Rust, and this seemed like a fun way to learn ARMv8 assembly.

> Will this ever be finished?

Depends, if I feel like it.

> Can I run this in production?

....why?

> How can I run this?
On a raspberry pi 4 or a Compute Module 4. The 3 might work too, but you'll have to change the periheral adresses.

Put `build/test.img` and `config.txt` on an SDCard alongside the `start4.elf` the Raspberry Pi foundation supplies and then boot your Pi from that.
Or serve those files from a TFTP server and net-boot your pi. The possibilities are endless.

It should print out the answers to (my) Advent of Code and then wait for you to press the 'r' key and reboot.  You can hit 1 and 2 to turn the on-board LED on or off, if you like shiny things.

Text will be outputted on the mini-uart interface, at 9600 bauds.
