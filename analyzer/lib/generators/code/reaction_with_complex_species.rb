module VersatileDiamond
  module Generators
    module Code

      # Stand guard that checks using source gas of reaction
      module ReactionWithComplexSpecies
        extend Forwardable

        def_delegators :reaction, :changes, :full_mapping
        def_delegators :reaction, :links, :clean_links, :relation_between

      protected

        def_delegator :reaction, :lateral?

      end

    end
  end
end
