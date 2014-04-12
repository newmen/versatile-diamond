module VersatileDiamond
  module Organizers

    # Contain some termination spec and set of dependent specs
    class DependentTermination < DependentSpec
      include MultiParentsSpec

      def to_s
        name
      end

      def inspect
        to_s
      end
    end

  end
end
