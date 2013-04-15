class Component
  include AnalysisTools

  def interpret(line, &block)
    super(line, method(:call_by_first_word), &block)
  end

private

  def call_by_first_word(line)
    method_name, args_str = head_and_tail(line)
    syntax_error('common.undefined_component', component: method_name) unless respond_to?(method_name)
    send(method_name, *convert_to_args(args_str))
  end

  def convert_to_args(args_str)
    args, options = split_args(args_str)
    args << options unless options.empty?
    args
  end

  def split_args(args_str)
    args = args_str.strip.split(/\s*,\s*/)
    options = {}

    hash_rgx = /\A(?<key>[a-z][a-z0-9_]*):\s+(?<value>.+)\Z/

    loop do
      break if args.last !~ hash_rgx
      options[$~[:key].to_sym] = $~[:value]
      args.pop
    end

    args.each_with_index do |arg, i|
      if arg =~ hash_rgx
        syntax_error('common.wrong_arguments_ordering')
      elsif arg =~ /\A(['"])([^(?:\\\1)]*)\1\Z/
        args[i] = $2
      elsif arg[0] == ?:
        args[i] = arg[1...(arg.length)].to_sym
      end
    end

    options = Hash[options.to_a.reverse]
    [args, options]
  end
end