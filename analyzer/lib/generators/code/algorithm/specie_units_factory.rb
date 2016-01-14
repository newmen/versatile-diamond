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
            @used_parents = Set.new
          end

          # Gets the specie creator unit
          # @return [Units::SpecieCreatorUnit] the unit for defines specie creation
          #   code block
          def creator
            Units::SpecieCreatorUnit.new(*default_args, @specie, @used_parents.to_a)
          end

        private

          # Gets the role of creating mono unit
          # @return [Module] the scope of methods which defines behavior of unit
          def behavior_role
            Units::SpecieBehavior
          end

          # Gets the object which provides global links
          # @return [Specie] specie which should be found by building algorigm
          def relations_checker
            @specie
          end

          # Stores the passed specie to internal collection
          # @param [Instances::SpecieInstance] uniq_parent which will be stored
          def remember_uniq_specie(uniq_parent)
            @used_parents << uniq_parent
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
