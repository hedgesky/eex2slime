require_relative 'eex2slime/version'
require_relative 'eex2slime/converter'

module EEx2Slime
  def self.convert!(input, format = :html)
    if format.to_s == "html"
      HTMLConverter.from_stream(input).to_s
    else
      EExConverter.from_stream(input).to_s
    end
  end
end