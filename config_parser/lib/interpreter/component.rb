module VersatileDiamond

  module Interpreter

    # The base interpreter component class
    # @abstract
    class Component < Interpreter::Base

      # Interprets line by first word of line
      # @param [String] line see at super same argument
      # @yeild see at super
      def interpret(line, &block)
        super(line, method(:call_by_first_word), &block)
      end

    private

      # Сalls self method where methond name is first word of the line
      # @param [String] line see at super interpret method same argument
      def call_by_first_word(line)
        method_name, args_str = head_and_tail(line)
        unless respond_to?(method_name)
          syntax_error('common.undefined_component', component: method_name)
        end

        send(method_name, *string_to_args(args_str))
      end

      # Stores concept in Chest
      # @param [Concept::Base] concept which will be stored
      # @raise [Errors::SyntaxError] if concept with same name was stored
      def store(concept)
        Chest.store(concept)
      rescue Concepts::KeyNameError => e
# p I18n.t("concepts.#{e.key}"), e.name
        syntax_error("concepts.errors.#{e.type}",
          key: I18n.t("concepts.#{e.key}"), name: e.name)
      end
    end

  end

end
