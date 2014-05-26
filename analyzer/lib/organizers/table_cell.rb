module VersatileDiamond
  module Organizers

    # Contain result of base spec compliance, and used as cells in dynamic
    # species table
    class TableCell
      extend Forwardable

      attr_reader :residual, :specs
      def_delegators :residual, :empty?

      # Inits the new table cell
      # @param [DependentBaseSpec | SpecResidual] residual the minimal possible rest
      # @param [Array] specs the optimal array of contained species
      def initialize(residual, specs = [])
        @residual, @specs = residual, specs
      end

      # Compares two table cells
      # @param [TableCell] other the comparable table cell
      # @return [Integer] the result of comparation
      def <=> (other)
        atoms_num == other.atoms_num ?
          accurate_compare(other) :
          atoms_num <=> other.atoms_num
      end

      # Adsorbs the minimal table cell
      # @param [TableCell] min the adsorbing table cell which should be more optimal
      #   than current table cell
      # @return [TableCell] the new more complete optimal table cell
      def adsorb(min)
        self.class.new(min.residual, specs + min.specs)
      end

    protected

      def_delegators :residual, :atoms_num, :relations_num

      # Counts number of contained species
      # @return [Integer] the number of contained species
      def specs_size
        specs.size
      end

    private

      # Compares two cells if them residuals have equal sizes of links
      # @param [TableCell] other the comparable cell
      # @return [Integer] the result of comparation
      def accurate_compare(other)
        relations_num == other.relations_num ?
          specs_size <=> other.specs_size :
          other.relations_num <=> relations_num
      end
    end

  end
end
