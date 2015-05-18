module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates nodes for sidepiece check algorithm graphs building
        class WhereNodesFactory < ReactionNodesFactory

          def initialize(generator, original_links)
            super(generator)
            @original_links = original_links
          end

        private

          # Creates node for passed spec with atom
          # @return [Node] new node which contain the correspond algorithm specie and
          #   atom
          def create_node(target_or_spec_atom)
            if target_or_spec_atom.is_a?(Symbol)
              lattice = @original_links[target_or_spec_atom].first.first.last.lattice
              TargetNode.new(target_or_spec_atom, lattice)
            else
              super
            end
          end
        end

      end
    end
  end
end
