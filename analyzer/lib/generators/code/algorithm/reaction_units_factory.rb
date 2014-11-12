module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction find algorithm units
        class ReactionUnitsFactory < BaseUnitsFactory

          # Initializes reaction find algorithm units factory
          # @param [EngineCode] generator the major code generator
          # @param [Reaction] reaction for which the algorithm is building
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
            @used_unique_species << nodes.first.uniq_specie

            if nodes.size == 1 && nodes.first.blunt?
              BaseReactionUnit.new(*default_args_for(nodes))
            else
              ReactantUnit.new(*default_args_for(nodes), nodes.map(&:atom))
            end
          end

          # Gets the reaction creator unit
          # @return [ReactionCreatorUnit] the unit for defines reaction creation code
          #   block
          def creator
            ReactionCreatorUnit.new(namer, @reaction, @used_unique_species.to_a)
          end

        private

          # Gets the default list of arguments for new unit
          # @param [Array] nodes from which will be gotten the unique specie
          # @return [Array] the list of default arguments
          def default_args_for(nodes)
            unique_specie = nodes.first.uniq_specie
            default_args + [unique_specie.original, unique_specie]
          end
        end

      end
    end
  end
end
