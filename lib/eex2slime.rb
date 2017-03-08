require_relative 'eex2slime/version'
require_relative 'eex2slime/converter'

module EEx2Slime
  def self.convert!(input)
    EExConverter.from_stream(input).to_s
  end
end
