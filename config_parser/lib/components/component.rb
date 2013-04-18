class Component < AnalysisTool
  def interpret(line, &block)
    super(line, method(:call_by_first_word), &block)
  end

private

  def call_by_first_word(line)
    method_name, args_str = head_and_tail(line)
    syntax_error('common.undefined_component', component: method_name) unless respond_to?(method_name)
    send(method_name, *string_to_args(args_str))
  end
end