module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction algorithm units
        # @abstract
        class BaseReactionUnitsFactory < BaseUnitsFactory

          # Initializes reaction algorithm units factory
          # @param [EngineCode] generator the major code generator
          def initialize(generator)
            super(generator)

            create_namer! # just create internal names accumulator
          end

          # Makes single specie unit for each nodes list
          # @param [Array] nodes for which the unit will be maked
          # @return [SingleParentNonRootSpecieUnit] the unit of code generation
          def make_unit(nodes)
            if nodes.map(&:dept_spec).uniq.size == 1
              make_single_unit(nodes)
            else
              make_multi_unit(nodes)
            end
          end

        private

          # Gets the list of default arguments which uses when new single unit creates
          # @param [Array] nodes from which the unit will be created
          # @return [Array] the array of default arguments
          def single_unit_args(nodes)
            default_args + [
              nodes.first.dept_spec,
              nodes.first.uniq_specie,
              nodes.map(&:atom)
            ]
          end

          # Gets the list of default arguments which uses when new multi unit creates
          # @param [Array] nodes from which the unit will be created
          # @return [Array] the array of default arguments
          def multi_unit_args(nodes)
            atoms_to_species = Hash[nodes.map { |n| [n.atom, n.uniq_specie] }]
            default_args + [atoms_to_species]
          end
        end

      end
    end
  end
end
