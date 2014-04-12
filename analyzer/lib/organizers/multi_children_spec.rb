module VersatileDiamond
  module Organizers

    # Also conatins children
    module MultiChildrenSpec
      extend Organizers::DisposedCollector

      collector_methods :child
    end

  end
end
