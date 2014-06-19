module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent reactions, theres and children
    # @abstract
    class DependentSpec < DependentSimpleSpec
      extend Collector

      collector_methods :there
    end

  end
end
