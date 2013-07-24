module VersatileDiamond

  module Interpreter

    class Environment < ComplexComponent
      def initialize(name)
        @concept = Concepts::Environment.add(name)
      end

      def targets(*names)
        @concept.targets = names
      end

      def aliases(**refs)
        @aliases ||= {}
        refs.each do |name, spec_name|
          @aliases[name] = Spec[spec_name.to_sym]
        end
      end

      def where(name, description)
        syntax_error('where.already_exists', name: name) if @wheres[name]
        where = Where.new(self, description)
        @wheres[name] = where
        nested(where)
      end
    end

  end

end
