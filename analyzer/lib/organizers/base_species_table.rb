module VersatileDiamond
  module Organizers

    # Represent the table of dynamic programming for organization of dependencies
    # between all wrapped base species
    class BaseSpeciesTable

      # Initialize table by array of species for which the table will be builded
      # @param [Array] base_specs the array of species
      def initialize(base_specs)
        @column_keys = sort(base_specs.reject { |spec| spec.simple? || spec.gas? })
        @table = {}

        build
      end

      # Finds best spec residue for passed specie
      # @param [DependentBaseSpec] base_spec the key of table
      # @return [SpecResidual] the minimal spec residue
      def best(base_spec)
        row = @table[base_spec]
        row ? min(row) : SpecResidual.empty(base_spec)
      end

    private

      # Builds dynamic table
      def build
        @column_keys.each { |spec| add(spec) }
      end

      # Stores record to table as key and correspond array of residuals
      # @param [DependentBaseSpec | SpecResidual] record the key of table
      # @return [Hash] the complete row for passed record
      def add(record)
        row = row_for(record)
        return row if row

        @table[record] = {}
        @column_keys.map { |key| @table[record][key] = find(key, record) }
        @table[record]
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
            row = add(rest)
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
        base_specs.sort { |a, b| b <=> a }
      end
    end

  end
end
