module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates nodes for reaction algorithm graphs building
        class ReactionNodesFactory < BaseNodesFactory
          # Initizalize reaction nodes factory
          # @param [EngineCode] generator the major code generator
          # @param [TypicalReaction] reaction for which the nodes will be gotten
          def initialize(generator, reaction)
            super(generator)
            @reaction = reaction
            @specs_to_uniques = {}
          end

          # Makes node for passed spec with atom
          # @return [Node] new node which contain the correspond algorithm specie and
          #   atom
          def get_node(spec_atom)
            spec, atom = spec_atom
            return atoms_to_nodes[atom] if atoms_to_nodes[atom]

            specie = get_unique_specie(spec)
            atoms_to_nodes[atom] = Node.new(specie.original, specie, atom)
          end

        private

          # Makes unique specie instance from passed spec
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   spec by which the unique algorithm specie will be maked
          # @return [UniqueSpecie] the wrapped specie code generator
          def get_unique_specie(spec)
            return @specs_to_uniques[spec] if @specs_to_uniques[spec]
            specie = specie_class(spec)
            @specs_to_uniques[spec] = UniqueSpecie.new(specie, specie.spec)
          end
        end

      end
    end
  end
end
