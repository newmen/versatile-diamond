module VersatileDiamond

  class ComplexComponent < Component
    def interpret(line)
      if line =~ /\A\s/ && @nested
        super { pass_line_to(@nested, line) }
      else
        @nested = nil if line !~ /\A\s/ && @nested
        super
      end
    end

  private

    def nested(instance)
      @nested = instance
    end
  end

end
