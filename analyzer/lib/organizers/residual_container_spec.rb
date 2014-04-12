module VersatileDiamond
  module Organizers

    # Provides methods for storing residual instance
    module ResidualContainerSpec

      attr_reader :rest

      # Stores the residual of atom difference operation
      # @param [SpecResidual] rest the residual of difference
      # @raise [RuntimeError] if residual already set
      def store_rest(rest)
        raise 'Residual already set' if @rest
        @rest = rest
      end
    end

  end
end
