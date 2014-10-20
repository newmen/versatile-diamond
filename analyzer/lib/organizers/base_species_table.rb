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

      # Finds best spec residue for passed specie
      # @param [DependentBaseSpec] base_spec the key of table
      # @return [SpecResidual] the minimal spec residue
      def best(base_spec)
        min(@table[base_spec])
      end

    private

      # Builds dynamic table
      def build
        @column_keys.each { |spec| add(spec) }
      end

      # Stores record to table as key and correspond array of residuals
      # @param [DependentBaseSpec | SpecResidual] record the key of table
      def add(record)
        cells = @column_keys.map { |key| find(key, record) }
        @table[record] = Hash[@column_keys.zip(cells)]
      end

      # Finds optimal solutions which storing to table all correpond residuals
      # @param [DependentBaseSpec] key the specie for which finds optimal table cell
      # @param [DependentBaseSpec | SpecResidual] record the minuend entity
      # @return [DependentBaseSpec | SpecResidual] the optimal value
      def find(key, record)
        if key.same?(record)
          return SpecResidual.empty(key)
        elsif key <= record
          rest = record - key
          if rest && rest < record
            row = row_for(rest) || add(rest)
            return min(row)
          end
        end

        record
      end

      # Checks that residual contain as record of table
      # @param [SpecResidual] the checking residual
      # @return [Hash] the row of table or nil if rest was never stored
      def row_for(rest)
        row = @table.find { |record, _| record.same?(rest) }
        row && row.last
      end

      # Finds optimal residue
      # @param [Hash] row in which will be found optimal cell
      # @return [SpecResidual] the optimal spec residual
      def min(row)
        row.values.min
      end

      # Sorts array of base species by them sizes from smaller to larger
      # @param [Array] base_specs the array of sorting species
      # @return [Array] the sorted array of base species
      def sort(base_specs)
        base_specs.sort do |a, b|
          if a.size == b.size
            a.external_bonds <=> b.external_bonds
          else
            b.size <=> a.size
          end
        end
      end
    end

  end
end
