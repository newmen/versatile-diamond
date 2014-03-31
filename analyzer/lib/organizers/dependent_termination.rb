module VersatileDiamond
  module Organizers

    # Contain some termination spec and set of dependent specs
    class DependentTermination < DependentSpec
      extend Forwardable

      def_delegators :@spec, :name

    end

  end
end
