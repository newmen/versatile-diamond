module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Contains two reactant nodes
        # @abstract
        class ChangeNode < Tools::TransparentProxy

          # @param [ReactantNode] original
          # @yield lazy other node
          def initialize(original, &other)
            super(original)
            @other = other
            @_called_other = nil
          end

          # @return [Boolean]
          def gas?
            original.spec.spec.gas?
          end

          # @return [Boolean]
          def transit?
            lattice != other.lattice
          end

          # @return [Boolean]
          def switch?
            gas? || other.gas?
          end

          # @return [Boolean]
          def different?
            (gas? && !other.gas?) || (!gas? && other.gas?)
          end

        private

          # @return [ReactantNode]
          def other
            @_called_other ||= @other.call
          end
        end

      end
    end
  end
end
