module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent specs
    class DependentBaseSpec < DependentSpec
      extend Forwardable

      def_delegators :@spec, :name

    end

  end
end
