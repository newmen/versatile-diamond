module VersatileDiamond
  module Generators
    module Code

      # Contains logic for generation typical reation
      class TypicalReaction < SpeciesReaction

        # Initializes typical reaction class code generator
        def initialize(*)
          super
          @_used_iterators = nil
        end

        # Typical reaction haven't sidepiece species
        # @return [Array] the empty array
        def sidepiece_species
          []
        end

      private

        # Gets the type of reaction
        # @return [String] the type of reaction
        def reaction_type
          concretizable? ? 'Central' : 'Typical'
        end

        # Gets the number of species which used as base class template argument
        # @return [Integer] the number of using species
        def template_specs_num
          complex_source_species.size
        end

        # Gets the collection of used crystal atom iterator classes
        # @return [Array] used crystal atom iterators
        # @override
        def used_iterators
          return @_used_iterators if @_used_iterators
          specs_atoms =
            if reaction.clean_links.empty?
              concretizable? ? reaction.complexes.map(&:lateral_targets) : []
            else
              reaction.clean_links.keys
            end

          lattices = specs_atoms.map(&:last).map(&:lattice)
          @_used_iterators = translate_to_iterators(lattices.to_set)
        end

        # Gets a list of code elements each of which uses in header file
        # @return [Array] the array of using objects in header file
        def head_used_objects
          complex_source_species
        end

        # Gets the arguments of find reaction method
        # @param [Specie] specie from which the reaction will be found
        # @return [String] the string with signature of find method
        def find_arguments_str(specie)
          "#{specie.class_name} *#{ANCHOR_SPECIE_NAME}"
        end

        # Builds find algorithm of current reaction from passed specie
        # @param [Specie] specie the one of using reactnat
        # @return [String] the cpp code string with find algorithm
        def find_algorithm_from(specie)
          Algorithm::ReactionFindBuilder.new(generator, self, specie).build
        end
      end

    end
  end
end
