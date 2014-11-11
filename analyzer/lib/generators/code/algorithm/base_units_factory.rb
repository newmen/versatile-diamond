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
          # @param [Specie] original_specie for which the unit will be created
          # @param [UniqueSpecie] unique_specie which will be stored in unit
          # @param [Array] atoms that corresponds to atoms of unique parent reaction
          # @return [SingleSpecieUnit] the unit for generation code of algorithm
          def create_single_specie_unit(original_specie, unique_specie, atoms)
            args = [generator, namer, original_specie, unique_specie, atoms]
            SingleSpecieUnit.new(*args)
          end
        end

      end
    end
  end
end
