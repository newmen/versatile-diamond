module VersatileDiamond
  module Generators
    module Code

      # Provides generation logic for reation which uses species
      # @abstract
      class SpeciesReaction < BaseReaction
        include Modules::ListsComparer
        include SpeciesUser
        include ReactionWithComplexSpecies

        LATERAL_CHUNKS_NAME = 'chunks'.freeze
        CHUNKS_INDEX_NAME = 'index'.freeze
        LIMITER_VAR_NAME = 'num'.freeze
        COUNTER_VAR_NAME = 'counter'.freeze

        # Initializes additional caches
        def initialize(*)
          super
          @_uniq_complex_source_species, @_concept_source_species = nil
        end

        # Gets the name of base class
        # @return [String] the parent type name
        def base_class_name
          template_args = concretizable? ? [reaction_type] : []
          template_args += [enum_name, template_specs_num]
          "#{outer_base_class_name}<#{template_args.join(', ')}>"
        end

        # Orders passed species
        # @param [Array] species the list of unique species which will be right ordered
        # @return [Array] the ordered source species
        def order_species(species)
          check_all_source!(species.map(&:proxy_spec).map(&:spec))
          species.sort { |*ss| ordering_rule(*ss.map(&:spec)) }
        end

      private

        # Gets the parent type of generating reaction
        # @return [String] the parent type of reaction
        # @override
        def outer_base_class_name
          concretizable? ? 'ConcretizableRole' : reaction_type
        end

        # Gets the ordered list of complex species which using as source of reaction
        # @reaturn [Array] the list of complex specie code generators
        def uniq_complex_source_species
          @_uniq_complex_source_species ||=
            specie_classes(concept_source_species.uniq(&:name))
        end

        # Gets ordered list of concept source specs
        # @return [Array] the list of concept reactants
        def concept_source_species
          @_concept_source_species ||= reaction.surface_source.sort do |*specs|
            ordering_rule(*specie_classes(specs).map(&:spec))
          end
        end

        # Provides the rule for ordering source species
        # @param [Oragnizers::DependentWrappedSpec] dept_spec1
        # @param [Oragnizers::DependentWrappedSpec] dept_spec2
        # @param [Array] specs the pair of comparing species
        # @return [Integer] the comparation result
        def ordering_rule(dept_spec1, dept_spec2)
          dept_spec2 <=> dept_spec1
        end
      end

    end
  end
end
