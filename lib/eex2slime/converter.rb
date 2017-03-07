require_relative 'hpricot_monkeypatches'

module EEx2Slime
  class Converter
    def to_s
      @slim
    end
  end

  class HTMLConverter < Converter
    def self.from_stream(stream)
      new(stream)
    end

    def initialize(html_or_stream)
      @slim = Hpricot(html_or_stream).to_slime
    end
  end

  class EExConverter < Converter
    def self.from_stream(stream)
      input =
        if File.exist?(stream)
          open(stream).read
        else
          stream
        end
      new(input)
    end

    def initialize(input)
      @erb = input
      prepare_curly_blocks!
      prepare_control_flow_statements!
      prepare_elixir_anonymous_functions!
      prepare_else_statements!
      prepare_elsif_statements!
      prepare_when_statements!
      prepare_elixir_condition_expressions!
      prepare_end_statements!
      prepare_regular_elixir_code!
      @slim = Hpricot(@erb).to_slime
    end

    private

    def prepare_curly_blocks!
      @erb.gsub!(/<%(.+?)\s*\{\s*(\|.+?\|)?\s*%>/) {
        %(<%#{$1} do #{$2}%>)
      }
    end

    def prepare_control_flow_statements!
      @erb.gsub!(/<%(-\s+)?((\s*(case|if|for|unless) .+?)|.+?do\s*(\|.+?\|)?\s*)-?%>/) {
        %(<elixir code="#{$2.gsub(/"/, '&quot;')}">)
      }
    end

    def prepare_elixir_anonymous_functions!
      @erb.gsub!(/<%(-\s+)?(.+ fn.*->\s*)-?%>/) {
        %(<elixir code="#{$2.gsub(/"/, '&quot;')}">)
      }
    end

    def prepare_else_statements!
      @erb.gsub!(/<%-?\s*else\s*-?%>/, %(</elixir><elixir code="else">))
    end

    def prepare_elsif_statements!
      @erb.gsub!(/<%-?\s*(elsif .+?)\s*-?%>/) {
        %(</elixir><elixir code="#{$1.gsub(/"/, '&quot;')}">)
      }
    end

    def prepare_when_statements!
      @erb.gsub!(/<%-?\s*(when .+?)\s*-?%>/) {
        %(</elixir><elixir code="#{$1.gsub(/"/, '&quot;')}">)
      }
    end

    def prepare_elixir_condition_expressions!
      @erb.gsub!(/<%-?\s*(.* ->)\s*-?%>/) {
        %(<elixir code="#{$1.gsub(/"/, '&quot;')}"></elixir>)
      }
    end

    def prepare_end_statements!
      @erb.gsub!(/<%\s*(end|}|end\s+-)\s*%>/, %(</elixir>))
    end

    def prepare_regular_elixir_code!
      @erb.gsub!(/<%-?(.+?)\s*-?%>/m) {
        %(<elixir code="#{$1.gsub(/"/, '&quot;')}"></elixir>)
      }
    end
  end
end
