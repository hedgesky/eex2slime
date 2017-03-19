# Patch Hpricot to support our custom <elixir> tags.
require 'hpricot'

Hpricot::XHTMLTransitional.tagset[:elixir] = [:code]

module SlimText
  def to_slime(lvl=0)
    return nil if textify.strip.empty?
    ('  ' * lvl) + %(| #{textify.gsub(/\s+/, ' ').strip})
  end

  # default implementation
  def textify
    to_s
  end
end

module BlankSlim
  def to_slime(_lvl=0)
    nil
  end
end

class Hpricot::CData
  include SlimText
end
class Hpricot::XMLDecl
  include SlimText
end
class Hpricot::Attributes
  include SlimText
end

class Hpricot::Text
  include SlimText

  def textify
    content.to_s
  end
end

class Hpricot::BogusETag
  include BlankSlim
end

class Hpricot::Comment
  include BlankSlim
end

class Hpricot::DocType
  def to_slime(lvl=0)
    if to_s.include? "xml"
      to_s.include?("iso-8859-1") ? "doctype xml ISO-88591" : "doctype xml"
    elsif to_s.include? "XHTML" or self.to_s.include? "HTML 4.01"
      available_versions = Regexp.union ["Basic", "1.1", "strict", "Frameset", "Mobile", "Transitional"]
      version = to_s.match(available_versions).to_s.downcase
      "doctype #{version}"
    else
      "doctype html"
    end
  end
end

class Hpricot::Elem
  BLANK_RE = /\A[[:space:]]*\z/

  def slime(lvl=0)
    r = '  ' * lvl

    return r + slime_elixir_code(r) if elixir?

    r += name unless skip_tag_name?
    r += slime_id
    r += slime_class
    r += slime_attributes
    r
  end

  def to_slime(lvl=0)
    if respond_to?(:children) and children
      [slime(lvl), children_slime(lvl)].join("\n")
    else
      slime(lvl)
    end
  end

  private

  def elixir?
    name == "elixir"
  end

  def children_slime(lvl)
    children
      .map { |c| c.to_slime(lvl+1) }
      .select { |e| !e.nil? }
      .join("\n")
  end

  def slime_elixir_code(r)
    lines = code.lines.drop_while { |line| line.strip.empty? }
    prettified_lines = prettify_lines_indentation(lines)
    prettified = prettified_lines.join(" \\\n#{r}  ")

    first_symbol = code.strip[0] == "=" ? "" : "- "
    first_symbol + prettified
  end

  def prettify_lines_indentation(lines)
    indent_level = lines.first.match(/^ */)[0].length
    lines.map do |line|
      next line.rstrip if line.length < indent_level
      next line.rstrip unless line.slice(0, indent_level).strip.empty?
      line.slice(indent_level .. -1).rstrip
    end
  end

  def code
    attributes["code"]
  end

  def skip_tag_name?
    div? && (has_id? || non_cryptic_classes.any?)
  end

  def slime_id
    return "" unless has_id?
    "#" << self['id']
  end

  def slime_class
    return "" unless has_class?
    return "" if non_cryptic_classes.empty?
    ".#{non_cryptic_classes.join('.')}"
  end

  def slime_attributes
    remove_css_class
    remove_attribute('id')
    return "" unless has_attributes?
    "[#{attrs_with_restored_interpolation}]"
  end

  def has_attributes?
    attributes.to_hash.any?
  end

  def has_id?
    has_attribute?('id') && !(BLANK_RE === self['id'])
  end

  def has_class?
    has_attribute?('class') && !(BLANK_RE === self['class'])
  end

  def div?
    name == "div"
  end

  def attrs_with_restored_interpolation
    regex = /\#{([^{}]+)}/
    attributes_as_html.to_s.strip.gsub(regex) do
      code = $1.gsub("&quot;", '"')
      "\#{ #{code} }"
    end
  end

  def remove_css_class
    if has_class? && cryptic_classes.any?
      self["class"] = cryptic_classes.join(" ")
    else
      remove_attribute("class")
    end
  end

  def non_cryptic_classes
    crypto_analyzer.last
  end

  def cryptic_classes
    crypto_analyzer.first
  end

  # We can have interpolation inside attributes.
  # Such classes should always be in attributes section (not shortened)
  # This handles cituations like this:
  #   <div class="form foo-<%= error_class f, :slug %>-bar"></div>
  def crypto_analyzer
    return [[], []] unless has_attribute?("class")
    @crypto_analyzer ||= begin
      class_value = self["class"].strip
      interpolation_regex = /[-\w]*\#{(?:[^{}]+)}[-\w]*/
      interpolated_classes = class_value.scan(interpolation_regex)
      class_value.gsub!(interpolation_regex, "")

      crypt, non_crypt = class_value.split(/\s+/).partition do |klass|
        klass.match(/[=#"&()]/)
      end
      [crypt + interpolated_classes, non_crypt]
    end
  end
end

class Hpricot::Doc
  def to_slime
    if respond_to?(:children) && children
      children.map(&:to_slime).reject(&:nil?).join("\n")
    else
      ''
    end
  end
end
