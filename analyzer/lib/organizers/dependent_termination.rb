module VersatileDiamond
  module Organizers

    # Contain some termination spec and set of dependent specs
    class DependentTermination < DependentSpec
      include MultiParentsSpec

      def_delegators :spec, :terminations_num

      # Termination spec could not be a specific spec
      # @return [Boolean] false
      def specific?
        false
      end

      def to_s
        name
      end

      def inspect
        to_s
      end
    end

  end
end
