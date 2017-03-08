require_relative 'hpricot_monkeypatches'

module EEx2Slime
  class EExConverter
    def self.from_stream(stream)
      input =
        if stream.is_a?(IO)
          stream.read
        else
          open(stream).read
        end
      new(input)
    end

    def initialize(input)
      @eex = input
      prepare_control_flow_statements!
      prepare_elixir_anonymous_functions!
      prepare_else_statements!
      prepare_elixir_condition_expressions!
      prepare_end_statements!
      prepare_regular_elixir_code!
      @slime = Hpricot(@eex).to_slime
    end

    def to_s
      @slime
    end

    private

    def prepare_curly_blocks!
      @eex.gsub!(/<%(.+?)\s*\{\s*(\|.+?\|)?\s*%>/) {
        %(<%#{$1} do #{$2}%>)
      }
    end

    def prepare_control_flow_statements!
      @eex.gsub!(/<%(-\s+)?((\s*(case|if|for|unless) .+?)|.+?do\s*(\|.+?\|)?\s*)-?%>/) {
        %(<elixir code="#{$2.gsub(/"/, '&quot;')}">)
      }
    end

    def prepare_elixir_anonymous_functions!
      @eex.gsub!(/<%(-\s+)?(.+ fn.*->\s*)-?%>/) {
        %(<elixir code="#{$2.gsub(/"/, '&quot;')}">)
      }
    end

    def prepare_else_statements!
      @eex.gsub!(/<%-?\s*else\s*-?%>/, %(</elixir><elixir code="else">))
    end

    def prepare_elixir_condition_expressions!
      @eex.gsub!(/<%-?\s*(.* ->)\s*-?%>/) {
        %(<elixir code="#{$1.gsub(/"/, '&quot;')}"></elixir>)
      }
    end

    def prepare_end_statements!
      @eex.gsub!(/<%=?\s*(end|}|end\s+-)\s*%>/, %(</elixir>))
    end

    def prepare_regular_elixir_code!
      @eex.gsub!(/<%-?(.+?)\s*-?%>/m) {
        %(<elixir code="#{$1.gsub(/"/, '&quot;')}"></elixir>)
      }
    end
  end
end
