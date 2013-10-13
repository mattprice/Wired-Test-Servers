#!/usr/bin/env ruby
#
# Copyright (c) 2013 Matthew Price, http://mattprice.me/
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

require 'fileutils'

# Configuration Data
DEST_DIR   = "/home/wired"
SRC_DIR    = "/home/wired/src"
BACKUP_DIR = "/home/wired/backups"

# Download links to the latest Zanka Software builds.
# These are tarballs since the original repo is down.
OLD_VERSIONS = {
   "2.0b53" => "https://github.com/nark/zanka/tarball/master",
   "2.0b51" => "http://zankasoftware.com/nightly/wired-2.0/wired-2.0-2010-06-09.tar.gz"
}

# Git commits hashes for Nark's newest builds.
REPO_URL = "https://github.com/nark/wired.git"
VERSIONS = {
   # NOTE: Commits after 6562c3 block non-encrypted connections by default. You can
   # change it in the config file, but this script doesn't do that automatically yet.
   # "2.0b55" => "6562c307baa21e15d85cb7b7c59064bc81ca1a7d",
   "2.0b55" => "HEAD",
   "2.0b54" => "792793f70817ca7a389868056c78031cd373e3fe",
}

# Download and install the archived builds:
# puts "*** Processing archived builds..." unless OLD_VERSIONS.count == 0
OLD_VERSIONS.each { |version, url|
   port       = Integer(version.scan(/\d/).join(''))
   file_name  = "wired-#{port}"
   wired_dir  = "#{DEST_DIR}/#{file_name}"
   source_dir = "#{SRC_DIR}/#{file_name}"

   # Check for existing installs.
   if (File.exists? wired_dir)
      puts "*** Detected existing Wired #{version} installation..."
      next
   end

   puts "*** Installing Wired #{version}..."

   # Download the source code.
   puts "    Downloading..."
   `wget -qO #{file_name}.tar.gz #{url}`

   # Verify download.
   unless (File.exists? "#{file_name}.tar.gz")
      puts "    ERROR: File download failed."
      next
   end

   # Unpack the source code.
   puts "    Unpacking..."
   `mkdir -p #{source_dir}`
   `tar -xzf #{file_name}.tar.gz -C #{source_dir} --strip-components 1`

   # Configure the server.
   if (port == 2053)
      source_dir += "/branches/P7/wired"
      `cp -r #{SRC_DIR}/#{file_name}/trunk/libwired/ #{source_dir}`
   end

   FileUtils.cd(source_dir) do
      puts "    Configuring..."
      `./configure --prefix=#{wired_dir}`

      puts "    Compiling..."
      `make`

      puts "    Installing..."
      `make install`
   end

   # Create a backup of the server.
   `mkdir -p #{BACKUP_DIR}`
   `cp -r #{wired_dir} #{BACKUP_DIR}/#{file_name}`

   # Clean up files
   puts "*** Cleaning up Wired #{version}..."
   `rm -rf #{file_name}.tar.gz`
   `rm -rf #{SRC_DIR}/#{file_name}`
}

# Download and install new builds:
# puts "*** Installing recent builds..." unless VERSIONS.count == 0
VERSIONS.each { |version, hash|
   port       = Integer(version.scan(/\d/).join(''))
   file_name  = "wired-#{port}"
   wired_dir  = "#{DEST_DIR}/#{file_name}"
   source_dir = "#{SRC_DIR}/#{file_name}"

   # Check for existing installs.
   if (File.exists? wired_dir)
      puts "*** Detected existing Wired #{version} installation..."
      next
   end

   puts "*** Installing Wired #{version}..."

   # Download the source code.
   puts "    Downloading..."
   `git clone -q #{REPO_URL} #{source_dir}`

   FileUtils.cd(source_dir) do
      `git checkout #{hash} -q`
      `git submodule init -q && git submodule sync -q && git submodule update -q`

      puts "    Configuring..."
      `./configure --prefix=#{wired_dir}`

      puts "    Compiling..."
      `make`

      puts "    Installing..."
      `make install`
   end

   # Create a backup of the server.
   `mkdir -p #{BACKUP_DIR}`
   `cp -r #{wired_dir} #{BACKUP_DIR}/#{file_name}`

   # Clean up files
   puts "*** Cleaning up Wired #{version}..."
   `rm -rf #{SRC_DIR}/#{file_name}`
}

# Remove the (now empty) source directory.
`rm -rf #{SRC_DIR}`