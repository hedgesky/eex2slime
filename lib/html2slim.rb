require_relative 'html2slim/version'
require_relative 'html2slim/converter'

module HTML2Slim
  def self.convert!(input, format=:html)
    if format.to_s == "html"
      HTMLConverter.from_stream(input)
    else
      ERBConverter.from_stream(input)
    end
  end
end