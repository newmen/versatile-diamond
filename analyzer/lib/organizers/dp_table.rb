module VersatileDiamond
  module Organizers

    # Provides base logic for dynamic programming table
    # @abstract
    class DpTable

      # Initialize table by array of entities for which the table will be builded
      # @param [Array] entities the array of entities
      def initialize(entities)
        @column_keys = sort(entities)
        @table = {}

        build
      end

      # Finds best entity residue for passed specie
      # @param [DependentBaseSpec | Chunk] entity the key of table
      # @return [SpecResidual | ChunkResidual] the minimal entity residue
      def best(entity)
        row = @table[entity]
        row ? min(row) : empty_residual(entity)
      end

    private

      # Builds dynamic table
      def build
        @column_keys.each { |entity| add(entity) }
      end

      # Stores record to table as key and correspond array of residuals
      # @param [Object] record the key of table
      # @return [Hash] the complete row for passed record
      def add(record)
        row = row_for(record)
        return row if row

        @table[record] = {}
        @column_keys.map { |key| @table[record][key] = find(key, record) }
        @table[record]
      end

      # Finds optimal solutions which storing to table all correpond residuals
      # @param [DependentBaseSpec | Chunk] key the entity for which finds optimal table
      #   cell
      # @param [Object] record the minuend entity
      # @return [Object] the optimal value
      def find(key, record)
        if same?(key, record)
          return empty_residual(key)
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
      # @param [SpecResidual | ChunkResidual] the checking residual
      # @return [Hash] the row of table or nil if rest was never stored
      def row_for(rest)
        row = @table.find { |record, _| record.same?(rest) }
        row && row.last
      end

      # Finds optimal residue
      # @param [Hash] row in which will be found optimal cell
      # @return [SpecResidual | ChunkResidual] the optimal residual
      def min(row)
        row.values.min
      end

      # Sorts array of entities by them sizes from larger to smaller
      # @param [Array] entities the array of sorting entities
      # @return [Array] the sorted array of entities
      def sort(entities)
        entities.sort { |a, b| b <=> a }
      end

      # Check that two passed instances are same
      # @param [MinuendSpec | MinuendChunk] one is the first comparing object
      # @param [MinuendSpec | MinuendChunk] two is the second comparing object
      # @return [Boolean] are equal passed instances or not
      def same?(one, two)
        one.same?(two)
      end
    end

  end
end
