module VersatileDiamond
  module Generators
    module Code

      # Contains logic for generation local reation
      class LocalReaction < BaseReaction
        include SpeciesUser
        include ReactionWithSimpleGas

        # Gets the name of base class
        # @return [String] the parent type name
        def base_class_name
          template_args = [
            parent.data_class_name,
            parent.class_name,
            enum_name,
            complex_source_specie.enum_name,
            complex_source_specie.role(atom_of_complex)
          ]

          "#{reaction_type}<#{template_args.join(', ')}>"
        end

        # Gets the atom of source complex specie
        # @return [Concepts::SpecificAtom] the atom that reacts with gas
        def atom_of_complex
          reaction.complex_source_spec_and_atom.last
        end

      private

        # Gets the type of reaction
        # @return [String] the type of reaction
        def reaction_type
          'Local'
        end

        # Gets the complex source specie of current reaction
        # @return [Specie] the complex source specie
        def complex_source_specie
          specie_class(reaction.complex_source_spec_and_atom.first)
        end

        # Gets a list of code elements each of which uses in header file
        # @return [Array] the array of using objects in header file
        def head_used_objects
          [parent]
        end

        # The local reaction could have just one parent ubiquitous reaction
        # @return [UbiquitousReaction] the parent reaction for current local reaction
        def parent
          parents.first
        end
      end

    end
  end
end
