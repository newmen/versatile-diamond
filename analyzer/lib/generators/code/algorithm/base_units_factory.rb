module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction find algorithm units
        # @abstract
        class BaseUnitsFactory

          # Initializes reaction find algorithm units factory
          # @param [EngineCode] generator the major code generator
          def initialize(generator)
            @generator = generator
            @namer = nil
          end

          # Provokes namer to save next checkpoint
          def remember_names!
            namer.checkpoint!
          end

          # Provokes namer to rollback names from last checkpoint
          def restore_names!
            namer.rollback!
          end

          # Makes unit that correspond to passed nodes
          # @param [Array] nodes for which the unit will be maked
          # @return [Units::BaseCheckerUnit] the unit of code generation
          def make_unit(nodes)
            nodes.one? ? make_mono_unit(nodes.first) : make_many_units(nodes)
          end

        private

          attr_reader :generator, :namer

          # Resets the internal variables which accumulates data when algorithm code
          # builds
          def create_namer!
            @namer = Units::NameRemember.new
          end

          # Creates mono unit by one node
          # @param [Nodes::BaseNode] node by which the mono unit will be created
          # @return [Units::MonoUnit] the unit for generation code that depends from
          #   passed node
          def make_mono_unit(node)
            remember_uniq_specie(node.uniq_specie)
            Units::MonoUnit.new(*default_args, node.uniq_specie, node.atom)
          end

          # Creates many units by list of nodes
          # @param [Array] nodes by which the many units will be created
          # @return [Units::ManyUnits] the unit for generation code that depends from
          #   passed nodes
          def make_many_units(nodes)
            units = nodes.map(&method(:make_mono_unit))
            Units::ManyUnits.new(*default_args, units)
          end

          # Gets the list of default arguments which uses when each new unit creates
          # @return [Array] the array of default arguments
          def default_args
            [generator, namer, context]
          end
        end

      end
    end
  end
end
