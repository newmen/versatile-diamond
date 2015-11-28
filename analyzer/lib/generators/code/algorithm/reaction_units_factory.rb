module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction find algorithm units
        class ReactionUnitsFactory < BaseReactionUnitsFactory

          # Initializes reaction find algorithm units factory
          # @param [EngineCode] generator the major code generator
          # @param [TypicalReaction] reaction for which the algorithm is building
          def initialize(generator, reaction)
            super(generator)
            @reaction = reaction
            @used_species = Set.new
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
            ReactantUnit.new(*single_unit_args(nodes), @reaction.reaction)
          end

          # Makes unit which contains many reactant species
          # @param [Array] nodes from which the unit will be created
          # @return [ManyReactantsUnit] which contains many unique specie
          def make_multi_unit(nodes)
            ManyReactantsUnit.new(*multi_unit_args(nodes), @reaction.reaction)
          end

          # Gets the list of default arguments which uses when new single unit creates
          # @param [Array] nodes from which the unit will be created
          # @return [Array] the array of default arguments
          # @override
          def single_unit_args(nodes)
            @used_species << nodes.first.uniq_specie
            super
          end

          # Gets the list of default arguments which uses when new multi unit creates
          # @param [Array] nodes from which the unit will be created
          # @return [Array] the array of default arguments
          # @override
          def multi_unit_args(nodes)
            @used_species += nodes.map(&:uniq_specie)
            super
          end
        end

      end
    end
  end
end
