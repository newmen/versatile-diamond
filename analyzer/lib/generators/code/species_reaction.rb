module VersatileDiamond
  module Generators
    module Code

      # Provides generation logic for reation which uses species
      # @abstract
      class SpeciesReaction < BaseReaction
        include SpeciesUser
        extend Forwardable

        ANCHOR_SPECIE_NAME = 'target'

        def_delegators :reaction, :links, :clean_links, :relation_between, :changes

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

        # Checks that current reaction is a tail of overall engine find algorithm
        # @return [Boolean] is final reaction in reactions tree or not
        def concretizable?
          !reaction.complexes.empty? #&& reaction.complexes.all?(&:lateral?)
        end

        # Gets the parent type of generating reaction
        # @return [String] the parent type of reaction
        # @override
        def outer_base_class_name
          concretizable? ? 'ConcretizableRole' : reaction_type
        end

        # Gets the list of complex species which using as source of reaction
        # @reaturn [Array] the list of complex specie code generators
        def complex_source_species
          reaction.surface_source.uniq(&:name).map(&method(:specie_class))
        end
      end

    end
  end
end
