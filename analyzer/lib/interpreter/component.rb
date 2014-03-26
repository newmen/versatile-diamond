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

      # Calls self method where method name is first word of the line
      # @param [String] line see at super interpret method same argument
      def call_by_first_word(line)
        method_name, args_str = head_and_tail(line)
        unless respond_to?(method_name)
          syntax_error('common.undefined_component', component: method_name)
        end

        send(method_name, *string_to_args(args_str))
      end

      # Stores concept in Chest
      # @param [Array] concepts the array of concepts
      # @raise [Errors::SyntaxError] if concept with same name was stored
      def store(*concepts)
        Tools::Chest.store(*concepts)
      rescue Tools::Chest::KeyNameError => e
        keyname_error(e)
      end

      # Gets concept from Chest
      # @param [Symbol] key the underscored concept class name
      # @param [Array] concepts see at #store same argument
      # @return [Concepts::Base] founded concept
      def get(key, *concepts)
        Tools::Chest.send(key, *concepts)
      rescue Tools::Chest::KeyNameError => e
        keyname_error(e)
      end

      # Handle KeyNameError from Chest
      # @param [Tools::Chest::KeyNameError] e the keyname exception object
      # @raise [Errors::SyntaxError] correspond message about keyname error
      def keyname_error(e)
        syntax_error("concepts.errors.#{e.type}",
          key: I18n.t("concepts.#{e.key}"), name: e.name)
      end
    end

  end
end
