require 'hpricot'

Hpricot::XHTMLTransitional.tagset[:ruby] = [:code]

module SlimText
  def to_slim(lvl=0)
    return nil if textify.strip.empty?
    ('  ' * lvl) + %(| #{textify.gsub(/\s+/, ' ').strip})
  end
end

module BlankSlim
  def to_slim(_lvl=0)
    nil
  end
end

class Hpricot::CData
  include SlimText

  def textify
    to_s
  end
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
  def to_slim(lvl=0)
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

  def slim(lvl=0)
    r = '  ' * lvl

    return r + slim_ruby_code(r) if ruby?

    r += name unless skip_tag_name?
    r += slim_id
    r += slim_class
    r += slim_attributes
    r
  end

  def to_slim(lvl=0)
    if respond_to?(:children) and children
      [slim(lvl), children_slim(lvl)].join("\n")
    else
      slim(lvl)
    end
  end

  private

  def children_slim(lvl)
    children
      .map { |c| c.to_slim(lvl+1) }
      .select { |e| !e.nil? }
      .join("\n")
  end

  def slim_ruby_code(r)
    lines = code.lines.drop_while { |line| line.strip.empty? }
    indent_level = lines.first.match(/^ */)[0].length
    prettified = lines.map do |line|
      line.slice(indent_level .. -1)
    end.join("#{r}- ")

    first_symbol = code.strip[0] == "=" ? "" : "- "
    first_symbol + prettified
  end

  def code
    attributes["code"]
  end

  def skip_tag_name?
    div? and (has_id? || has_class?)
  end

  def slim_id
    has_id?? "##{self['id']}" : ""
  end

  def slim_class
    has_class?? ".#{self['class'].strip.split(/\s+/).join('.')}" : ""
  end

  def slim_attributes
    remove_attribute('class')
    remove_attribute('id')
    has_attributes?? "[#{attributes_as_html.to_s.strip}]" : ""
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

  def ruby?
    name == "ruby"
  end

  def div?
    name == "div"
  end
end

class Hpricot::Doc
  def to_slim
    if respond_to?(:children) and children
      children
        .map { |x| x.to_slim }
        .select{|e| !e.nil? }
        .join("\n")
    else
      ''
    end
  end
end
