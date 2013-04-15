module AnalysisTools
  def constantize(name)
    class_name = name.split('_').map(&:capitalize).join
    Object.const_get(class_name)
  end

  def interpret(line, zero_level_func)
    if !has_indent?(line)
      zero_level_func.call(line)
    else
      (block_given? && yield) || syntax_error('common.wrong_hierarchy')
    end
  end

  def head_and_tail(line)
    line.split(/\s+/, 2)
  end

  def pass_line_to(component, line)
# puts "PASSING \"#{line}\" to #{component.class}"
    component.interpret(decrease_indent(line)) if component
  end

  def syntax_error(*args)
    message = args.shift
    message = "#{self.class.to_s.underscore}#{message}" if message[0] == '.'
    raise AnalyzingError.new(Analyzer.config_path, Analyzer.line_number, I18n.t(message, *args))
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
