## EEx2Slime

[![Gem Version](https://badge.fury.io/rb/eex2slime.svg)](https://badge.fury.io/rb/eex2slime)
[![Build Status](https://travis-ci.org/hedgesky/eex2slime.svg?branch=master)](https://travis-ci.org/hedgesky/eex2slime)

Script for converting EEx templates to [Slime](http://slime-lang.com). Slime is a lightweight template language.

## Usage

You may convert files using the included executable `eex2slime`:

```bash
$ gem install eex2slime
# Suggested usage way. Will create .slime files near original .eex ones
$ eex2slime lib/web/templates/
# Optionally delete .eex files after convertion. Be sure you have a backup!
$ eex2slime --delete lib/web/templates/

# Another ways:
$ eex2slime foo.html.eex                   # outputs to foo.html.slime by default
$ eex2slime foo.html.eex bar.html.slime    # outputs to bar.html.slime
$ eex2slime foo.html.eex -                 # outputs to stdout
$ cat foo.eex | eex2slime                  # input from stdin, outputs to stdout
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

It might fail in some cases, but in general yes, it does! I've checked it on the opensourced [changelog.com app](https://github.com/thechangelog/changelog.com) and the [hex.pm app](https://github.com/hexpm/hexpm). After a bit of preparing this tool finely converted all EEx templates.

CI runs tests on Rubies 2.2, 1.9.3. Ruby 1.8.7 isn't supported.

## Known issues

### Incorrect HTML

Using incorrect html in original templates will break inner HTML parser. Example (notice misplaced slash):

```html
<img width="75" / height="75">
```

### Nested interpolation

It doesn't play well with Slime. This:

```erb
<img src="<%= static_url(@conn, "/images/podcasts/#{@podcast.slug}.svg") %>">
```

should be rewritten to:

```erb
<% image_url = static_url(@conn, "/images/podcasts/#{@podcast.slug}.svg") %>
<img src="<%= image_url %>">
```

### Inline `if`'s interpolation

Such constructions aren't supported:

```erb
<article class="<%= if index == 0 do %>is-active<% end %>"></article>
```

### Non-closed tags

```erb
# header.html.eex. Notice non-closed div.
<div class="container">

# body.html.eex
body content is expected to be inside container

# footer.html.eex. Closing div.
</div>
```

Slime doesn't support this, so `eex2slime` will produce non-expected output: body won't be nested inside the container. Be wary.

### Multiline elixir

There are three ways to achieve multiline elixir in Slime:

```slim
- a = 1
- b = 2

- a = 1 \
  b = 2

elixir:
  a = 1
  b = 2
```

First approach leads to errors in such cases:

```slim
- some_function(first,
- second)
```

I decided to use the second approach, but technically the third one is possible, too.

## License

This project uses MIT license.
