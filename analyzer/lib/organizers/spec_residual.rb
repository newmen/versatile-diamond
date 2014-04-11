module VersatileDiamond
  module Organizers

    # Contain some residual of find diff between base species
    class SpecResidual
      include Minuend

      class << self
        # Gets empty residual instance
        # @return [SpecResidual] the empty residual instance
        def empty
          new({}, Set.new)
        end
      end

      attr_reader :links

      # Initialize residual by hash of links and residual border atoms
      # @param [Hash] links the links between some atoms
      # @param [Set] atoms the residual border atoms
      def initialize(links, atoms)
        @links = links
        @atoms = atoms
      end

      # Checks that current minuend instance is empty or not
      # @return [Boolean] empty or not
      def empty?
        super && @atoms.empty?
      end

    protected

      # Provides purge condition for initial minuend instance
      # @return [Proc] the condition for purging
      def purge_condition
        Proc.new { |atom, links| links.empty? && !@atoms.include?(atom) }
      end

      # Makes a new residual
      # @param [Array] links_arr the array that represent relations between atoms
      # @param [Set] residual_atoms the residual atoms after diff operation
      # @return [SpecResidual] the new residual
      def make_residual(links_arr, residual_atoms)
        SpecResidual.new(Hash[links_arr], residual_atoms + @atoms)
      end
    end

  end
end
