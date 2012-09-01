#!/usr/bin/env ruby
#
# Copyright (c) 2012 Matthew Price, http://mattprice.me/
# Copyright (c) 2012 Ember Code, http://embercode.com/
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
DEST_DIR = "/home/wired"
SRC_DIR  = "#{DEST_DIR}/src/"

# Download links to the latest Zanka Software builds.
# These are tarballs since the original repo is down.
OLD_VERSIONS = {
   # "2.0b53" => "https://github.com/nark/zanka/tarball/master",
   # "2.0b51" => "http://zankasoftware.com/nightly/wired-2.0/wired-2.0-2010-06-09.tar.gz"
}

# Git commits hashes for Nark's newest builds.
REPO_URL = "https://bitbucket.org/nark/wired.git"
VERSIONS = {
   # "2.0b55" => "HEAD",
   # "2.0b54" => "792793f70817ca7a389868056c78031cd373e3fe",
}

# Make any required directories.
puts "*** Creating required subdirectories..."
`mkdir -p #{SRC_DIR}`

# Download and install the archived builds:
# puts "*** Processing archived builds..." unless OLD_VERSIONS.count == 0
OLD_VERSIONS.each { |version, url|
   port          = version.scan(/\d/).join('')
   output_folder = "wired-#{port}"

   puts "*** Installing Wired #{version}..."

   # Download the source code.
   puts "    Downloading..."
   `wget -qO #{output_folder}.tar.gz #{url}`

   # Unpack the source code.
   puts "    Unpacking..."
   `mkdir -p #{DEST_DIR}/#{output_folder}`
   `mkdir -p #{SRC_DIR}/#{output_folder}`
   `tar -xzf #{output_folder}.tar.gz -C #{SRC_DIR}/#{output_folder} --strip-components 1`

   # Configure the server.
   cd_dir = (port == 2053) ? "#{SRC_DIR}/#{output_folder}/branches/P7/wired/" : output_folder
   FileUtils.cd("#{SRC_DIR}/#{cd_dir}") do
      puts "    Configuring..."
      `./configure --prefix=#{DEST_DIR}/#{output_folder}`
      puts "    Compiling..."
      `make`
      puts "    Installing..."
      `make install`
   end

   # Clean up files
   puts "*** Cleaning up Wired #{version}..."
   `rm -rf #{output_folder}.tar.gz #{output_folder}`
   `rm -rf #{SRC_DIR}/#{output_folder}`
}

# Download and install new builds:
# puts "*** Installing recent builds..." unless VERSIONS.count == 0
VERSIONS.each { |version, url|
   port = version.scan(/\d/).join('')
   # `git clone --recursive #{REPO_URL}`
}