require_relative 'hpricot_monkeypatches'

module HTML2Slim
  class Converter
    def to_s
      @slim
    end
  end

  class HTMLConverter < Converter
    def initialize(html)
      @slim = Hpricot(html).to_slim
    end
  end

  class ERBConverter < Converter
    def initialize(input)
      @erb = read_erb(input)
      prepare_curly_blocks!
      prepare_control_flow_statements!
      prepare_else_statements!
      prepare_elsif_statements!
      prepare_when_statements!
      prepare_end_statements!
      prepare_regular_ruby_code!
      @slim ||= Hpricot(@erb).to_slim
    end

    private

    # input may be either string or IO.
    # open.read makes it works for files & IO
    def read_erb(input)
      if File.exists?(input)
        open(input).read
      else
        input
      end
    end

    def prepare_curly_blocks!
      @erb.gsub!(/<%(.+?)\s*\{\s*(\|.+?\|)?\s*%>/) {
        %(<%#{$1} do #{$2}%>)
      }
    end

    def prepare_control_flow_statements!
      @erb.gsub!(/<%(-\s+)?((\s*(case|if|for|unless|until|while) .+?)|.+?do\s*(\|.+?\|)?\s*)-?%>/) {
        %(<ruby code="#{$2.gsub(/"/, '&quot;')}">)
      }
    end

    def prepare_else_statements!
      @erb.gsub!(/<%-?\s*else\s*-?%>/, %(</ruby><ruby code="else">))
    end

    def prepare_elsif_statements!
      @erb.gsub!(/<%-?\s*(elsif .+?)\s*-?%>/) {
        %(</ruby><ruby code="#{$1.gsub(/"/, '&quot;')}">)
      }
    end

    def prepare_when_statements!
      @erb.gsub!(/<%-?\s*(when .+?)\s*-?%>/) {
        %(</ruby><ruby code="#{$1.gsub(/"/, '&quot;')}">)
      }
    end

    def prepare_end_statements!
      @erb.gsub!(/<%\s*(end|}|end\s+-)\s*%>/, %(</ruby>))
    end

    def prepare_regular_ruby_code!
      @erb.gsub!(/<%-?(.+?)\s*-?%>/m) {
        %(<ruby code="#{$1.gsub(/"/, '&quot;')}"></ruby>)
      }
    end
  end
end
