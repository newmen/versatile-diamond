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
