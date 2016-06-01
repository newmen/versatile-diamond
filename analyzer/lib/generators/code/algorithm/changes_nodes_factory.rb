module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates nodes for reaction applying algorithm
        class ChangesNodesFactory

          # @param [EngineCode] generator the major code generator
          def initialize(generator)
            @reactants_factory = ReactionNodesFactory.new(generator)
            @sources = {}
            @products = {}
          end

          # @param [Array] source spec-atom pair
          # @param [Array] product spec-atom pair
          # @return [Nodes::SourceNode]
          def source_node(source, product)
            original = reactant_node(source)
            @sources[original] ||=
              Nodes::SourceNode.new(original) { product_node(source, product) }
          end

          # @param [Array] source spec-atom pair
          # @param [Array] product spec-atom pair
          # @return [Nodes::SourceNode]
          def product_node(source, product)
            original = reactant_node(product)
            @products[original] ||=
              Nodes::ProductNode.new(original) { source_node(source, product) }
          end

        private

          # @param [Array] spec_atom
          # @return [Nodes::ReactantNode]
          def reactant_node(spec_atom)
            @reactants_factory.get_node(spec_atom)
          end
        end

      end
    end
  end
end
