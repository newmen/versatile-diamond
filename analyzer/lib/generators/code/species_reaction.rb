module VersatileDiamond
  module Generators
    module Code

      # Provides generation logic for reation which uses species
      # @abstract
      class SpeciesReaction < BaseReaction
        include SpeciesUser
        extend Forwardable

        ANCHOR_SPECIE_NAME = 'target'.freeze
        SIDEPIECE_SPECIE_NAME = 'sidepiece'.freeze

        def_delegators :reaction, :links, :clean_links, :relation_between, :changes

        # Initializes additional caches
        def initialize(*)
          super
          @_complex_source_species, @_concept_source_species = nil
        end

        # Gets the name of base class
        # @return [String] the parent type name
        def base_class_name
          template_args = concretizable? ? [reaction_type] : []
          template_args += [enum_name, template_specs_num]
          "#{outer_base_class_name}<#{template_args.join(', ')}>"
        end

      protected

        def_delegator :reaction, :lateral?

      private

        # Gets the parent type of generating reaction
        # @return [String] the parent type of reaction
        # @override
        def outer_base_class_name
          concretizable? ? 'ConcretizableRole' : reaction_type
        end

        # Gets the ordered list of complex species which using as source of reaction
        # @reaturn [Array] the list of complex specie code generators
        def complex_source_species
          @_complex_source_species ||=
            concept_source_species.uniq(&:name).map(&method(:specie_class))
        end

        # Gets ordered list of concept source specs
        # @return [Array] the list of concept reactants
        def concept_source_species
          # we should sort because order is important when getting target specie index
          # the sort order should be same as in BaseReactionCreatorUnit#initialize
          # method
          @_concept_source_species ||= reaction.surface_source.sort do |ca, cb|
            da, db = [ca, cb].map(&method(:specie_class)).map(&:spec)
            da <=> db
          end
        end
      end

    end
  end
end
