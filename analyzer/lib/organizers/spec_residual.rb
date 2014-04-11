module VersatileDiamond
  module Organizers

    # Contain some residual of find diff between base species
    class SpecResidual
      include Minuend

      class << self
        # Gets empty residual instance
        # @return [SpecResidual] the empty residual instance
        def empty
          new({})
        end
      end

      attr_reader :links

      # Initialize residual by hash of links
      # @param [Hash] links the links between some atoms
      def initialize(links)
        @links = links
      end
    end

  end
end
