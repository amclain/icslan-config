# AMX ICSLan Config Script


*This script configures AMX ICSLan and DXLINK devices
for use in a NetLinx system.*


To set a device to 192.168.1.2, hold the ID button.
Continue holding the button as the lights blink back and
forth slowly. Release the button when the lights flash
rapidly. The device will reboot and appear at the static
IP.

When configuring multiple devices, having ping running
continuously in a separate terminal will show when
devices are ready to connect to. Running this script
in a virtual machine will allow simultaneous access
to the static devices appearing on the 192.168.1.0
subnet, as well as NetLinx Diagnostics displaying the
online tree of the control system subnet to ensure the
configuration for each device took effect.

*Tested on Linux. May not work on other platforms.*


**RBENV - Ruby Installer:**
[https://github.com/sstephenson/rbenv#basic-github-checkout](https://github.com/sstephenson/rbenv#basic-github-checkout)
