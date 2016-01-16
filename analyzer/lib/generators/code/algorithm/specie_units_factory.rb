module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates specie find algorithm units
        class SpecieUnitsFactory < BaseUnitsFactory

          # Initializes specie find algorithm units factory
          # @param [EngineCode] generator the major code generator
          # @param [Specie] specie for which the algorithm is building
          def initialize(generator, specie)
            super(generator)
            @specie = specie
          end

          # Gets the specie creator unit
          # @return [Units::SpecieCreatorUnit] the unit for defines specie creation
          #   code block
          def creator
            Units::SpecieCreatorUnit.new(*default_args)
          end

        private

          # Gets the checking context which will be passed to each creating unit
          # @return [Specie] the context which targeted to inner specie
          def context
            @specie
          end

          # Creates checker unit from one node
          # @param [Nodes::SpecieNode] node by which the checker unit will be created
          # @return [Units::BaseCheckerUnit] the unit for generation code that depends
          #   from passed node
          # @override
          def make_mono_unit(node)
            node.scope? ? make_many_units(node.split) : super
          end
        end

      end
    end
  end
end
