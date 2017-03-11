require_relative "hpricot_monkeypatches"

module EEx2Slime
  class Converter
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
      prepare_elixir_inside_attributes!
      prepare_regular_elixir_code!
      @slime = Hpricot(@eex).to_slime
    end

    def to_s
      @slime
    end

    private

    def prepare_control_flow_statements!
      regex1 = /<%(?:-\s+)?((\s*(case|if|for|unless) ((?:(?!%>).)+)?))-?%>/
      regex2 = /<%(?:-\s+)?(((?:(?!%>).)+)?do\s*(\|.+?\|)?\s*)-?%>/
      @eex.gsub!(regex1) { %(<elixir code="#{$1.gsub(/"/, '&quot;')}">) }
      @eex.gsub!(regex2) { %(<elixir code="#{$1.gsub(/"/, '&quot;')}">) }
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

    # test string:
    #   <div class="form <%= a() %> " data="<%= b() %> another"></div>
    #   <%= another() %>
    def prepare_elixir_inside_attributes!
      # ="                ensure we are inside attributes
      # ([^"]*)           capture other attributes
      # <%=               ensure we are inside outputting elixir tag
      # ((?:(?!%>).)+)    capture code, don't span across multiple elixir tags
      # \s*               swallow spaces
      # -?%>              end of elixir tag
      #
      # Example match data:
      #   Match 1
      #   1.  form
      #   2.  a()
      #   Match 2
      #   1.
      #   2.  b()
      regex = /="([^"]*)<%=((?:(?!%>).)+)\s*-?%>/
      @eex.gsub!(regex) {
        # use variables, because gsub changes $1 and $2 values
        attrs = $1
        elixir = $2.gsub('"', "&quot;").strip
        %Q(="#{attrs}\#{#{elixir}})
      }
    end

    def prepare_regular_elixir_code!
      @eex.gsub!(/<%-?(.+?)\s*-?%>/m) {
        %(<elixir code="#{$1.gsub(/"/, '&quot;')}"></elixir>)
      }
    end
  end
end
