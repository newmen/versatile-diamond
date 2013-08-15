module VersatileDiamond
  module Interpreter
    module Support

      # Provides interpreter instances for RSpec
      module Handbook
        include Tools::Handbook

        set(:dimensions) { Dimensions.new }
        set(:elements) { Elements.new }
        set(:gas) { Gas.new }
        set(:surface) { Surface.new }
        set(:events) { Events.new }
        set(:reaction) { Reaction.new('reaction name') }
      end

    end
  end
end