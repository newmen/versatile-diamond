module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Also contains the different dependent spec
        class ReactantNode < BaseNode

          # Makes reaction links graph vertex from passed node
          # @return [Array] the reaction links graph vertex
          def spec_atom
            [spec.spec, atom]
          end

          def inspect
            "⁝#{super}⁝"
          end

        private

          # Gets dependent specie which is context for aggregation own atom properties
          # @param [Oraganizers::ProxyParentSpec] the spec where internal atom is
          #   defined
          def context_spec
            spec
          end
        end

      end
    end
  end
end
