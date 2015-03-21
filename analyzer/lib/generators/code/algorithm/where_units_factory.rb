module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates sidepiece check algorithm units
        class WhereUnitsFactory < BaseUnitsFactory

          # Initializes sidepiece check algorithm units factory
          # @param [EngineCode] generator the major code generator
          # @param [WhereLogic] where for which the algorithm is building
          def initialize(generator, where)
            super(generator)
            @where = where

            create_namer! # just create internal names accumulator
            @sidepieces = Set.new
          end

          # Makes unit for passed nodes
          # @param [Array] nodes for which the unit will be maked
          # @return [BaseUnit] the unit of code generation
          def make_unit(nodes)
            if nodes.all?(&:none?)
              make_targets_unit(nodes)
            else
              make_sidepieces_unit(nodes)
            end
          end

          # Gets the lambda calling unit
          # @return [WhereCreatorUnit] the unit for call the lambda with sidepieces
          def creator
            WhereCreatorUnit.new(namer, @sidepieces.to_a)
          end

        private

          # Makes unit with targets of where object
          # @param [Array] nodes for which the unit will be maked
          def make_targets_unit(nodes)
          end

          # Makes unit with targets of where object
          # @param [Array] nodes for which the unit will be maked
          def make_sidepieces_unit(nodes)
          end
        end

      end
    end
  end
end
