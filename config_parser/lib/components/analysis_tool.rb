module VersatileDiamond

  class AnalysisTool
    include ArgumentsParser
    include SyntaxChecker

    def interpret(line, zero_level_func, &block)
      if !has_indent?(line)
        zero_level_func.call(line)
      else
        block_given? ? block.call : syntax_error('common.wrong_hierarchy')
      end
    end

    def head_and_tail(line)
      line.split(/\s+/, 2)
    end

    def pass_line_to(component, line)
  # puts "PASSING \"#{line}\" to #{component.class}"
      component.interpret(decrease_indent(line))
    end

  private

    def has_indent?(line)
      match = line.scan(/\A(\t|  )?(.+)\Z/).first
      syntax_error('common.extra_space') if $2 && $2[0] == ' ' && $2[1] != ' '
      match.first
    end

    def decrease_indent(line)
      line[0] == "\t" ? line[0] = '' : line[0..1] = ''
      line
    end
  end

end
