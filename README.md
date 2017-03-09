## EEx2Slime

[![Gem Version](https://badge.fury.io/rb/eex2slime.svg)](https://badge.fury.io/rb/eex2slime)

Script for converting EEx templates to [Slime](http://slime-lang.com). Slime is a lightweight template language.

## Usage

You may convert files using the included executable `eex2slime`.

    $ eex2slime -h

    Usage: eex2slime INPUT_FILENAME_OR_DIRECTORY [OUTPUT_FILENAME_OR_DIRECTORY] [options]
            --trace                      Show a full traceback on error
        -d, --delete                     Delete EEx files
        -h, --help                       Show this message
        -v, --version                    Print version

Alternatively, to convert files or strings on the fly in your application, you may do so by calling `EEx2Slime.convert!(file)`.

## Installation

    gem install eex2slime

## Regards

Huge thanks to [Maiz Lulkin](https://github.com/joaomilho) and his original [html2slim repo](https://github.com/slim-template/html2slim).
