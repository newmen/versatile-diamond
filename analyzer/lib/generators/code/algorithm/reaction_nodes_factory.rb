module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates nodes for reaction algorithm graphs building
        class ReactionNodesFactory < BaseNodesFactory
        private

          # Gets the class of creating unique instance
          # @return [Class] the class of unique reactant specie which instnace will be
          #   stored in new node
          def instance_class
            Instances::UniqueReactant
          end

          # Creates node for passed spec with atom
          # @param [Array] spec_atom by which the new node will be maked
          # @return [Nodes::ReactantNode] new node which contain the correspond
          #   algorithm specie and atom
          def create_node(spec_atom)
            spec, atom = spec_atom
            specie = get_unique_specie(spec)
            Nodes::ReactantNode.new(generator, specie, atom)
          end
        end

      end
    end
  end
end
