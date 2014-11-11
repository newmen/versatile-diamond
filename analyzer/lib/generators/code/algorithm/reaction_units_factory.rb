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
            create_reactant_unit(nodes)
          end

          # Gets the reaction creator unit
          # @return [ReactionCreatorUnit] the unit for defines reaction creation code
          #   block
          def creator
            ReactionCreatorUnit.new(namer, @reaction, @used_unique_species.to_a)
          end

        private

          # Creates single specie unit and remember used unique specie
          # @param [Array] nodes by which the multi atoms unit will be created
          # @return [ReactantUnit] the unit for generation code that depends from
          #   passed nodes
          def create_reactant_unit(nodes)
            unique_specie = nodes.first.uniq_specie
            @used_unique_species << unique_specie

            original_specie = unique_specie.original
            args = default_args + [original_specie, unique_specie, nodes.map(&:atom)]
            ReactantUnit.new(*args)
          end
        end

      end
    end
  end
end
