module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The basic class for reaction algorithm builder units
        class BaseReactionUnit < BaseUnit

          # Initializes the empty unit of code builder algorithm
          # @param [Array] args the arguments of #super method
          # @param [UniqueSpecie] unique_specie which uses in current building
          #   algorithm
          def initialize(*args, unique_specie)
            super(*args)
            @unique_specie = unique_specie
          end

          # By default assigns the variable name of original specie
          def first_assign!
            namer.assign(SpeciesReaction::ANCHOR_SPECIE_NAME, unique_specie)
          end

          def inspect
            "BRU:(#{inspect_name_of(unique_specie)})"
          end

        private

          attr_reader :unique_specie

        end

      end
    end
  end
end
