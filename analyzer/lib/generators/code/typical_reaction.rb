module VersatileDiamond
  module Generators
    module Code

      # Contains logic for generation typical reation
      class TypicalReaction < SpeciesReaction

        # Initializes typical reaction class code generator
        def initialize(*)
          super
          @_children = nil

          @_used_iterators = nil
          @_lateral_chunks = nil
          @_sidepiece_species = nil
        end

        # Gets list of sidepiece species from all children reactions
        # @return [Array] the list of sidepiece species which can concretize current
        #   reaction
        def sidepiece_species
          @_sidepiece_species ||= children.flat_map(&:sidepiece_species).uniq
        end

        # Gets all minimal lateral reaction chunks
        # @return [Array] the list of all minimal lateral reaction chunks
        def lateral_chunks
          @_lateral_chunks ||= LateralChunks.new(generator, self, children)
        end

        # Gets the index of passed specie reactant
        # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
        #   for which the index will returned
        # @return [Integer] the index of passed specie or nil if reaction have just one
        #   reactant
        def target_index(spec)
          concept_source_species.one? ? nil : concept_source_species.index(spec)
        end

        # Gets builder of check lateral algorighm from passed specie
        # @param [Specie] specie from which the algorithm will build
        # @return [CheckLateralsFindBuilder] the builder of checkLaterals method
        #   code
        def check_laterals_builder_from(specie)
          builder_class = Algorithm::CheckLateralsFindBuilder
          builder_class.new(generator, lateral_chunks, specie)
        end

      private

        # Verifies that passed species belongs to source species set
        # @param [Array] species which will be checked
        def check_all_source!(specs)
          unless lists_are_identical?(concept_source_species, specs)
            msg = 'The passed species do not belongs to set of source species'
            raise ArgumentError, msg
          end
        end

        # Orders children lateral reaction
        # @return [Array] the ordered children lateral reactions list
        # @override
        def children
          @_children ||= super.sort_by(&:chunk)
        end

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
          concept_source_species.size
        end

        # Gets the collection of used crystal atom iterator classes
        # @return [Array] used crystal atom iterators
        # @override
        def used_iterators
          return @_used_iterators if @_used_iterators
          specs_atoms =
            if reaction.clean_links.empty?
              concretizable? ? lateral_chunks.targets.to_a : []
            else
              reaction.clean_links.keys
            end

          lattices = specs_atoms.map(&:last).map(&:lattice)
          @_used_iterators = translate_to_iterators(lattices.to_set)
        end

        # Gets a list of code elements each of which uses in header file
        # @return [Array] the array of using objects in header file
        def head_used_objects
          uniq_complex_source_species + sidepiece_species
        end

        # The body of typical reaction depends from children lateral reactions
        # @return [Array] the list of children lateral reactions
        def body_include_objects
          concretizable? ? (sidepiece_species + children) : []
        end

        # Gets the arguments of find reaction method
        # @param [Specie] specie from which the reaction will be found
        # @return [String] the string with signature of find method
        def find_arguments_str(specie)
          "#{specie.class_name} *#{Specie::TARGET_SPECIE_NAME}"
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
          var_name = "#{LATERAL_CHUNKS_NAME}[#{lateral_chunks_num}]"
          ptrs = (['nullptr'] * lateral_chunks_num).join(', ')
          "SingleLateralReaction *#{var_name} = { #{ptrs} }"
        end

        # Builds look around algorithm for find all possible lateral reactions
        # @return [String] the string with cpp code of look around algorithm
        def look_around_algorithm
          Algorithm::LookAroundFindBuilder.new(generator, lateral_chunks).build
        end

        # Gets the arguments of check laterals method
        # @param [Specie] specie from which lateral reaction can be found
        # @return [String] the string with signature of find method
        def check_laterals_arguments_str(specie)
          "#{specie.class_name} *#{Specie::SIDE_SPECIE_NAME}"
        end

        # Builds check laterals algorithm of current reaction from passed specie
        # @param [Specie] specie the one of using sidepiece specie
        # @return [String] the cpp code string with find algorithm
        def check_laterals_algorithm_from(specie)
          check_laterals_builder_from(specie).build
        end

        # Builds algorithm for creating right lateral reaction after that all possible
        # chunks was found and passed to this method with number of them
        #
        # @return [String] the cpp code string with algorithm of selection from
        #   available set of chunks
        def select_from_algorithm
          Algorithm::LateralReactionSelectBuilder.new(generator, lateral_chunks).build
        end

        # Builds reaction applying algorithm
        # @return [String] the cpp code string with algorithm of reaction applying
        def do_it_algorithm
          Algorithm::ReactionDoItBuilder.new(generator, self).build
        end
      end

    end
  end
end
