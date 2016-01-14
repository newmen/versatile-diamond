module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates specie find algorithm units
        class SpecieUnitsFactory < BaseUnitsFactory
          include Modules::ListsComparer

          # Initializes specie find algorithm units factory
          # @param [EngineCode] generator the major code generator
          # @param [Specie] specie for which the algorithm is building
          def initialize(generator, specie)
            super(generator)
            @specie = specie
          end

          # Resets the internal namer variable and clear set of collected unique
          # parent species
          def reset!
            create_namer!
            @used_unique_parents = Set.new
          end

          # Makes unit that correspond to passed nodes
          # @param [Array] nodes for which the unit will be maked
          # @return [BaseCheckerUnit] the unit of code generation
          def make_unit(nodes)
            nodes.size == 1 ? from_mono_node(nodes.first) : make_many_units(nodes)
          end

          # Gets the specie creator unit
          # @return [SpecieCreatorUnit] the unit for defines specie creation code block
          def creator
            SpecieCreatorUnit.new(*default_args, @specie, @used_unique_parents.to_a)
          end

        private

          # Creates mono unit by one node
          # @param [SpecieNode] node by which the mono unit will be created
          # @return [MonoUnit] the unit for generation code that depends from passed
          #   node
          def make_mono_unit(node)
            @used_unique_parents << node.uniq_specie
            MonoUnit.new(*default_args, @specie, node.uniq_specie, node.atom)
          end

          # Creates many units by list of nodes
          # @param [Array] nodes by which the many units will be created
          # @return [ManyUnits] the unit for generation code that depends from
          #   passed nodes
          def make_many_units(nodes)
            ManyUnits.new(*default_args, nodes.map(&method(:from_mono_node)))
          end

          # Creates checker unit from one node
          # @param [SpecieNode] node by which the checker unit will be created
          # @return [BaseCheckerUnit] the unit for generation code that depends from
          #   passed node
          def from_mono_node(node)
            node.scope? ? make_many_units(node.split) : make_mono_unit(node)
          end
        end

      end
    end
  end
end
