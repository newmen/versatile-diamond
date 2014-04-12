module VersatileDiamond
  module Organizers

    # Also conatins children
    module MultiChildrenSpec
      extend Organizers::Collector

      collector_methods :child
    end

  end
end