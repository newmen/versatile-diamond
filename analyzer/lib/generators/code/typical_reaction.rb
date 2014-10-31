module VersatileDiamond
  module Generators
    module Code

      # Contains logic for generation typical reation
      class TypicalReaction < ReactionWithComplexSpecies

        # Initializes typical reaction class code generator
        def initialize(*)
          super
          @_used_iterators = nil
        end

        # Gets the name of base class
        # @return [String] the parent type name
        def base_class_name
          args = laterable? ? [reaction_type] : []
          args += [enum_name, complex_source_species.size]
          "#{outer_base_class_name}<#{args.join(', ')}>"
        end

      private

        # Checks that reaction has lateral children
        # @return [Boolean] is laterable reaction or not
        def laterable?
          !reaction.complexes.empty? && reaction.complexes.all?(&:lateral?)
        end

        # Gets the parent type of generating reaction
        # @return [String] the parent type of reaction
        # @override
        def outer_base_class_name
          if laterable?
            'LaterableRole'
          elsif reaction.complexes.empty?
            reaction_type
          else
            raise 'Тот самый случай'
          end
        end

        # Gets the type of reaction
        # @return [String] the type of reaction
        def reaction_type
          'Typical'
        end

        # Gets the collection of used crystal atom iterator classes
        # @return [Array] used crystal atom iterators
        # @override
        def used_iterators
          return @_used_iterators if @_used_iterators
          lattices = reaction.positions.map(&:first).map(&:last).map(&:lattice)
          @_used_iterators = translate_to_iterators(lattices.to_set)
        end

        # Gets a list of code elements each of which will be included in header file
        # @return [Array] the array of header including objects
        def head_include_objects
          used_iterators + complex_source_species + [common_base_class_file]
        end
      end

    end
  end
end
