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

      # Initialize residual by hash of links and residual border atoms
      # @param [Hash] links the links between some atoms
      # @param [Set] border_atoms the residual border atoms
      def initialize(links, border_atoms = Set.new)
        @links = links
        @border_atoms = border_atoms
      end

      # Checks that other spec has same border atoms and links between them
      # @param [DependentBaseSpec] other the comparable spec
      # @return [Boolean] same or not
      def same?(other)
        return false unless links_size == other.links_size
        Mcs::SpeciesComparator.contain?(self, other, separated_multi_bond: true)
      end

      # Checks that current minuend instance is empty or not
      # @return [Boolean] empty or not
      def empty?
        super && @border_atoms.empty?
      end

    protected

      # Provides purge condition for initial minuend instance
      # @return [Proc] the condition for purging
      def purge_condition
        Proc.new { |atom, links| links.empty? && !@border_atoms.include?(atom) }
      end

      # Makes a new residual
      # @param [Array] links_arr the array that represent relations between atoms
      # @param [Set] residual_atoms the residual border atoms after diff operation
      # @return [SpecResidual] the new residual
      def make_residual(links_arr, residual_atoms)
        SpecResidual.new(Hash[links_arr], residual_atoms + @border_atoms)
      end
    end

  end
end
