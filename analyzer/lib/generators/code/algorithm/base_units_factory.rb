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

        private

          attr_reader :generator, :namer

          # Resets the internal variables which accumulates data when algorithm code
          # builds
          def create_namer!
            @namer = NameRemember.new
          end

          # Creates single specie unit
          # @param [UniqueReaction] unique_specie for which the unit will be created
          # @param [Array] atoms that corresponds to atoms of unique parent reaction
          # @return [SingleSpecieUnit] the unit for generation code of algorithm
          def create_single_specie_unit(unique_specie, atoms)
            args = [generator, namer, unique_specie.original, unique_specie, atoms]
            SingleSpecieUnit.new(*args)
          end
        end

      end
    end
  end
end
