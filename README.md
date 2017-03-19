## EEx2Slime

[![Gem Version](https://badge.fury.io/rb/eex2slime.svg)](https://badge.fury.io/rb/eex2slime)
[![Build Status](https://travis-ci.org/hedgesky/eex2slime.svg?branch=master)](https://travis-ci.org/hedgesky/eex2slime)

Script for converting EEx templates to [Slime](http://slime-lang.com). Slime is a lightweight template language.

## Usage

You may convert files using the included executable `eex2slime`:

```bash
$ gem install eex2slime

$ eex2slime foo.html.eex                   # outputs to foo.html.slime by default
$ eex2slime foo.html.eex bar.html.slime    # outputs to bar.html.slime
$ eex2slime foo.html.eex -                 # outputs to stdout
$ cat foo.eex | eex2slime                  # input from stdin, outputs to stdout
$ eex2slime dir/                           # convert all .eex files recursively
$ eex2slime --delete dir/                  # delete .eex files after convertion. Be sure you have a backup!
```

Alternatively you could use the following API:

```ruby
require 'eex2slime'
EEx2Slime.convert('path/to/file')
EEx2Slime.convert_string('<nav class="navbar"></nav>')
```

## Installation

    gem install eex2slime

## Regards

Huge thanks to [Maiz Lulkin](https://github.com/joaomilho) and his original [html2slim repo](https://github.com/slim-template/html2slim).

## Does it really work?

It might fail in some cases, but in general yes, it does! I've checked it on the opersourced [changelog.com app](https://github.com/thechangelog/changelog.com). After a bit of preparing this tool finely converted all EEx templates.

CI runs tests on Rubies 2.2, 1.9.3. Ruby 1.8.7 isn't supported.

## Known issues

- Incorrect HTML will break inner HTML parser. Example (notice misplaced slash):

    ```html
    <img width="75" / height="75">
    ```

- Nested interpolation won't play well with Slime. This:

    ```erb
    <img src="<%= static_url(@conn, "/images/podcasts/#{@podcast.slug}.svg") %>">
    ```

    should be rewritten to:

    ```erb
    <% image_url = static_url(@conn, "/images/podcasts/#{@podcast.slug}.svg") %>
    <img src="<%= image_url %>">
    ```

- This library doesn't support inline `if`'s interpolation:

    ```erb
    <!-- such constructions aren't supported -->
    <article class="<%= if index == 0 do %>is-active<% end %>"></article>
    ```

- With EEx you could do something like this:

    ```erb
    # header.html.eex
    <div class="container">

    # body.html.eex
    body content is expected to be inside container div

    # footer.html.eex
    </div>
    ```

    Slime doesn't support this, so `eex2slime` will produce non-expected output (body won't be nested inside the container). Be wary.


## License

This project uses MIT license.
