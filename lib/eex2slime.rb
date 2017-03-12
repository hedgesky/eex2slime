# This library converts EEx templates to Slime. It's based on html2slim
# library by @joaomilho. Usage examples are in README.

require_relative 'eex2slime/version'
require_relative 'eex2slime/converter'

module EEx2Slime
  def self.convert(input)
    Converter.from_stream(input).to_s
  end

  def self.convert_string(eex)
    Converter.new(eex).to_s
  end
end
