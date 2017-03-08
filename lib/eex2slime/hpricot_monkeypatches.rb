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

  def children_slime(lvl)
    children
      .map { |c| c.to_slime(lvl+1) }
      .select { |e| !e.nil? }
      .join("\n")
  end

  def slime_elixir_code(r)
    lines = code.lines.drop_while { |line| line.strip.empty? }
    indent_level = lines.first.match(/^ */)[0].length
    prettified_lines = lines.map do |line|
      line.slice(indent_level .. -1).rstrip
    end
    prettified = prettified_lines.join(" \\\n#{r}  ")

    first_symbol = code.strip[0] == "=" ? "" : "- "
    first_symbol + prettified
  end

  def code
    attributes["code"]
  end

  def skip_tag_name?
    div? and (has_id? || has_class?)
  end

  def slime_id
    return "" unless has_id?
    "##{self['id']}"
  end

  def slime_class
    return "" unless has_class?
    ".#{self['class'].strip.split(/\s+/).join('.')}"
  end

  def slime_attributes
    remove_attribute('class')
    remove_attribute('id')
    return "" unless has_attributes?
    "[#{attributes_as_html.to_s.strip}]"
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

  def elixir?
    name == "elixir"
  end

  def div?
    name == "div"
  end
end

class Hpricot::Doc
  def to_slime
    if respond_to?(:children) and children
      children
        .map { |x| x.to_slime }
        .select{|e| !e.nil? }
        .join("\n")
    else
      ''
    end
  end
end
