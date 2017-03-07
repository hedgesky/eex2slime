## EEx2Slime

Script for converting HTML and EEx files to [Slime](http://slime-lang.com) templates. Slime is a lightweight template language.

## Usage

You may convert files using the included executables `html2slime` and `eex2slime`.

    # eex2slime -h

    Usage: eex2slime INPUT_FILENAME_OR_DIRECTORY [OUTPUT_FILENAME_OR_DIRECTORY] [options]
            --trace                      Show a full traceback on error
        -d, --delete                     Delete EEx files
        -h, --help                       Show this message
        -v, --version                    Print version

    # html2slime -h

    Usage: html2slime INPUT_FILENAME_OR_DIRECTORY [OUTPUT_FILENAME_OR_DIRECTORY] [options]
            --trace                      Show a full traceback on error
        -d, --delete                     Delete HTML files
        -h, --help                       Show this message
        -v, --version                    Print version

Alternatively, to convert files or strings on the fly in your application, you may do so by calling `EEx2Slime.convert!(file, format)` where format is either `:html` or `:eex`.

## Regards

Huge thanks to [Maiz Lulkin](https://github.com/joaomilho) and his original [html2slim repo](https://github.com/slim-template/html2slim).
