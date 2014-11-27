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
            @used_species_pairs = Set.new
          end

          # Makes single specie unit for each nodes list
          # @param [Array] nodes for which the unit will be maked
          # @return [SingleParentNonRootSpecieUnit] the unit of code generation
          def make_unit(nodes)
            dept_spec = nodes.first.dept_spec
            unique_specie = nodes.first.uniq_specie
            @used_species_pairs << [dept_spec, unique_specie]

            args = default_args
            args += [
              dept_spec,
              unique_specie,
              nodes.map(&:atom),
              @reaction.reaction
            ]

            ReactantUnit.new(*args)
          end

          # Gets the reaction creator unit
          # @return [ReactionCreatorUnit] the unit for defines reaction creation code
          #   block
          def creator
            args = [generator.classifier, namer, @reaction, @used_species_pairs.to_a]
            ReactionCreatorUnit.new(*args)
          end
        end

      end
    end
  end
end
