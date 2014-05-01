#!/usr/bin/env ruby

# This script configures AMX ICSLan and DXLINK devices
# for use in a NetLinx system.
# 
# To set a device to 192.168.1.2, hold the ID button.
# Continue holding the button as the lights blink back and
# forth slowly. Release the button when the lights flash
# rapidly. The device will reboot and appear at the static
# IP.
# 
# When configuring multiple devices, having ping running
# continuously in a separate terminal will show when
# devices are ready to connect to. Running this script
# in a virtual machine will allow simultaneous access
# to the static devices appearing on the 192.168.1.0
# subnet, as well as NetLinx Diagnostics displaying the
# online tree of the control system subnet to ensure the
# configuration for each device took effect.
# 
# Tested on Linux. May not work on other platforms.
# 
# RBENV - Ruby Installer:
# https://github.com/sstephenson/rbenv#basic-github-checkout
# 
# -----------------------------------------------------------------------------
# 
# The MIT License (MIT)
# 
# Copyright (c) 2014 Alex McLain
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
# -----------------------------------------------------------------------------


require 'ionian'
require 'highline/import'
require 'timeout'

Thread.abort_on_exception = true


next_device_file = 'next_device.txt'

unless File.exist? next_device_file
  File.open(next_device_file, 'w') { |f| f.puts 12000 }
end

next_device = File.open(next_device_file).read.strip

# Prompt for user input.
ip_address    = ask("IP Address: ") { |q| q.default = "192.168.1.2" }
device_number = ask("Device: ")     { |q| q.default = next_device }

device_number = device_number.to_i


raise ArgumentError, 'Device number not set.' unless device_number > 0

# Telnet.

# NOTE: nil waits to receive another response before continuing.
# This is useful for comands like "set connection" that send two responses
# before the device is ready for another command.
commands = [
  "set ip",
  "",
  "d", # DHCP.
  "y",
  
  "set device #{device_number}",
  
  "set connection",
  "a",
  "",
  "",
  "",
  "",
  "",
  "y",
  nil,
  
  "reboot"
]

socket = nil
Timeout.timeout 5 do
  socket = Ionian::Socket.new host: ip_address.strip
end

while socket.has_data?
  puts socket.read_all
end

commands.each do |command|
  if command
    socket.write "#{command}\r\n"
    socket.flush
    
    sleep 0.25
    
    socket.read_match.each { |match| puts match[1] }
  else
    # Wait for another response before continuing.
    socket.read_match.each { |match| puts match[1] }
  end
end

puts socket.read_all if socket.has_data?
socket.close

# Increment device number for next execution of script.
next_device = device_number + 1
File.open('next_device.txt', 'w') { |f| f.puts next_device }
