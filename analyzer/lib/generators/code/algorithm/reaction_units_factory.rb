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
            @used_unique_species = Set.new
          end

          # Makes single specie unit for each nodes list
          # @param [Array] nodes for which the unit will be maked
          # @return [SingleParentSpecieUnit] the unit of code generation
          def make_unit(nodes)
            unique_specie = nodes.first.uniq_specie
            @used_unique_species << unique_specie

            args = default_args
            args += [
              unique_specie.original,
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
            ReactionCreatorUnit.new(namer, @reaction, @used_unique_species.to_a)
          end
        end

      end
    end
  end
end
