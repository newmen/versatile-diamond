module VersatileDiamond
  module Generators
    module Code

      # Creates yaml config file with rates of all using reactions
      class ReactionsRatesYaml < YamlFile

        # @return [Array]
        def reactions
          ordered_reactions = code_class.reactions.sort_by(&:enum_name)
          ordered_reactions.map { |r| [r.enum_name, r.reaction.reaction] }
        end

        # @param [Float]
        # @return [String]
        def fix_value(value)
          value == 0 ? '0' : ('%e' % value)
        end

        # @return [String]
        def template_name
          'reactions'
        end
        alias :file_name :template_name
      end

    end
  end
end
