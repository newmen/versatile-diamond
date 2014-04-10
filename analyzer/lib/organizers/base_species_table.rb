module VersatileDiamond
  module Organizers

    # Represent the table of dynamic programming for organization of dependencies
    # between all wrapped base species
    class BaseSpeciesTable

      # Initialize table by array of species for which the table will be builded
      # @param [Array] base_specs the array of species
      def initialize(base_specs)
        @column_keys = sort(base_specs)
        @table = {}

        build
      end

      # Finds best table cell for passed specie
      # @param [DependentBaseSpec] base_spec the key of table
      # @return [TableCell] the best table cell with minimal residue
      def best(base_spec)
        min(@table[base_spec])
      end

    private

      # Builds dynamic table
      def build
        @column_keys.each { |spec| add(spec) }
      end

      # Stores record to table as key and correspond array solutions for each
      # element of species set
      #
      # @param [DependentBaseSpec | Residual] record the key of table
      def add(record)
        cells = @column_keys.map { |key| find(key, record) }
        @table[record] = Hash[@column_keys.zip(cells)]
      end

      # Finds optimal solutions which is store to table cell, by previes builded
      # table cells
      #
      # @param [DependentBaseSpec] key the specie for which finds optimal table cell
      # @param [DependentBaseSpec | Residual] record the minuend entity
      # @return [TableCell] the table cell with optimal decomposition by another
      #   species
      def find(key, record)
        if key.links_size < record.links_size
          rest = record.residual(key)
          row = row_for(rest)
          unless row
            add(rest)
            row = @table[rest]
          end

          TableCell.new(rest, [key]).adsorb(min(row))
        else
          TableCell.new(record)
        end
      end

      # Checks that residual contain as record of table
      # @param [Residual] the checking residual
      # @return [Hash] the row of table or nil if rest was never stored
      def row_for(rest)
        row = @table.find { |record, _| record.same?(rest) }
        row && row.last
      end

      # Finds optimal table cell
      # @param [Hash] row in which will be found optimal cell
      # @return [TableCell] the optimal table cell
      def min(row)
        row.values.min
      end

      # Sorts array of base species by them sizes from smaller to larger
      # @param [Array] base_specs the array of sorting species
      # @return [Array] the sorted array of base species
      def sort(base_specs)
        base_specs.sort do |a, b|
          if a.size == b.size
            b.external_bonds <=> a.external_bonds
          else
            a.size <=> b.size
          end
        end
      end
    end

  end
end
