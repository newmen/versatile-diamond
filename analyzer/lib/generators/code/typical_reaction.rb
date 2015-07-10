module VersatileDiamond
  module Generators
    module Code

      # Contains logic for generation typical reation
      class TypicalReaction < SpeciesReaction

        # Initializes typical reaction class code generator
        def initialize(*)
          super
          @_used_iterators = nil
          @_lateral_chunks = nil
        end

        # Typical reaction haven't sidepiece species
        # @return [Array] the empty array
        # TODO: deprecated?
        def sidepiece_species
          []
        end

        # Gets all minimal lateral reaction chunks
        # @return [Array] the list of all minimal lateral reaction chunks
        def lateral_chunks
          return @_lateral_chunks if @_lateral_chunks

          root_chunks = children.flat_map(&:internal_chunks).uniq
          @_lateral_chunks =
            LateralChunks.new(self, children.map(&:chunk), root_chunks)
        end

        # Gets the index of passed specie reactant
        # @param [Specie] specie for which the index will returned
        # @return [Integer] the index of passed specie or nil if reaction have just one
        #   reactant
        def target_index(specie)
          complex_source_species.size == 1 ? nil : complex_source_species.index(specie)
        end

      private

        # Checks that current reaction is a tail of overall engine find algorithm
        # @return [Boolean] is final reaction in reactions tree or not
        def concretizable?
          !children.empty?
        end

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
              concretizable? ? reaction.children.map(&:lateral_targets) : []
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

        # Gets the maximal number of lateral reaction chunks
        # @return [Integer] the maximal number of lateral reaction chunks
        def lateral_chunks_num
          lateral_chunks.root_times
        end

        # Gets the string by which chunks of lateral reactions define
        # @return [String] the string with null defined chunks of lateral reactions
        def define_lateral_chunks
          ptrs = (['nullptr'] * lateral_chunks_num).join(', ')
          "SingleLateralReaction *chunks[#{lateral_chunks_num}] = { #{ptrs} }"
        end

        # Builds look around algorithm for find all possible lateral reactions
        # @return [String] the string with cpp code of look around algorithm
        def look_around_algorithm
        end
      end

    end
  end
end
