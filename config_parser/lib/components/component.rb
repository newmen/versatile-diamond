module VersatileDiamond

  class Component < AnalysisTool
    def interpret(line, &block)
      super(line, method(:call_by_first_word), &block)
    end

  private

    def call_by_first_word(line)
      method_name, args_str = head_and_tail(line)
      unless respond_to?(method_name)
        syntax_error('common.undefined_component', component: method_name)
      end

      send(method_name, *string_to_args(args_str))
    end
  end

end
