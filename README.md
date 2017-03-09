## EEx2Slime

[![Gem Version](https://badge.fury.io/rb/eex2slime.svg)](https://badge.fury.io/rb/eex2slime)

Script for converting EEx templates to [Slime](http://slime-lang.com). Slime is a lightweight template language.

## Usage

You may convert files using the included executable `eex2slime`:

    $ eex2slime foo.eex              # output to foo.slime
    $ eex2slime foo.eex bar.slime    # output to bar.slime
    $ eex2slime foo.eex -            # output to stdout
    $ cat foo.eex | eex2slime        # input from stdin, output to stdout
    $ eex2slime dir/                 # convert all .eex files recursively
    $ eex2slime --delete dir/        # delete .eex files after convertion. Be sure you have a backup!

Alternatively you could use the following API:

    require 'eex2slime'
    EEx2Slime.convert('path/to/file')
    EEx2Slime.convert_string('<nav class="navbar"></nav>')

## Installation

    gem install eex2slime

## Regards

Huge thanks to [Maiz Lulkin](https://github.com/joaomilho) and his original [html2slim repo](https://github.com/slim-template/html2slim).
