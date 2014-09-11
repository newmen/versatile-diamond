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
      # @param [Array] specs the array of optimal contained species
      def initialize(residual, specs = [])
        @residual, @specs = residual, specs
      end

      # Compares two table cells
      # @param [TableCell] other the comparable table cell
      # @return [Integer] the result of comparation
      def <=> (other)
        if atoms_num == other.atoms_num
          accurate_compare(other)
        else
          atoms_num <=> other.atoms_num
        end
      end

      # Adsorbs the minimal table cell if it more optimal
      # @param [TableCell] min the adsorbing table cell which should be more optimal
      #   than current table cell
      # @return [TableCell] the more complete optimal table cell
      def adsorb_if_more_optimal(min)
        if !min.specs.empty? && min.relations_num < relations_num
          self.class.new(min.residual, specs + min.specs)
        else
          self
        end
      end

    protected

      def_delegators :residual, :atoms_num, :relations_num

      # Counts number of contained species
      # @return [Integer] the number of contained species
      def specs_size
        specs.size
      end

      # Counts the total number of atoms in all contained species
      # @return [Integer] the total number of all atoms
      def specs_atoms_num
        specs.map(&:atoms_num).reduce(:+)
      end

    private

      # Compares two cells if them residuals have equal sizes of links
      # @param [TableCell] other the comparable cell
      # @return [Integer] the result of comparation
      def accurate_compare(other)
        if relations_num == other.relations_num
          specs_compare(other)
        else
          other.relations_num <=> relations_num
        end
      end

      # Compares two cells by internal spec atoms number
      # @param [TableCell] other the comparable cell
      # @return [Integer] the comparation result
      def specs_compare(other)
        if specs_size == other.specs_size
          other.specs_atoms_num <=> specs_atoms_num
        else
          specs_size <=> other.specs_size
        end
      end
    end

  end
end
