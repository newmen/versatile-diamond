module VersatileDiamond
  module Generators
    module Code

      # Contains logic for generation local reation
      class LocalReaction < BaseReaction
        extend Forwardable

        def_delegator :reaction, :complex_source_spec_and_atom

      private

        # Gets the type of reaction
        # @return [String] the type of reaction
        def reaction_type
          'Local'
        end
      end

    end
  end
end
