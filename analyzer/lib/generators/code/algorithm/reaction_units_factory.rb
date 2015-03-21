module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction find algorithm units
        class ReactionUnitsFactory < BaseUnitsFactory

          # Initializes reaction find algorithm units factory
          # @param [EngineCode] generator the major code generator
          # @param [TypicalReaction] reaction for which the algorithm is building
          def initialize(generator, reaction)
            super(generator)
            @reaction = reaction

            create_namer! # just create internal names accumulator
            @used_species = Set.new
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

          # Gets the reaction creator unit
          # @return [ReactionCreatorUnit] the unit for defines reaction creation code
          #   block
          def creator
            ReactionCreatorUnit.new(namer, @reaction, @used_species.to_a)
          end

        private

          # Makes unit which contains one specie
          # @param [Array] nodes from which the unit will be created
          # @return [ReactantUnit] which contains one unique specie
          def make_single_unit(nodes)
            dept_spec = nodes.first.dept_spec
            unique_specie = nodes.first.uniq_specie
            @used_species << unique_specie

            args = default_args + [
              dept_spec,
              unique_specie,
              nodes.map(&:atom),
              @reaction.reaction
            ]

            ReactantUnit.new(*args)
          end

          # Makes unit which contains many reactant species
          # @param [Array] nodes from which the unit will be created
          # @return [ReactantUnit] which contains many unique specie
          def make_multi_unit(nodes)
            @used_species += nodes.map(&:uniq_specie)
            atoms_to_species = Hash[nodes.map { |n| [n.atom, n.uniq_specie] }]
            ManyReactantsUnit.new(*default_args, atoms_to_species, @reaction.reaction)
          end
        end

      end
    end
  end
end
