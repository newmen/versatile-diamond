module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Describes species array variable
        class SpeciesArray < Core::Collection

          DEFAULT_NAME = Code::Specie::INTER_SPECIE_NAME

          class << self
            # @param [NameRemember] namer
            # @param [Array] instances
            # @param [Array] values
            # @option [String] :name which will be pluralized
            # @return [SpeciesArray]
            def [](namer, instances, type, values = nil, name: DEFAULT_NAME)
              super(namer, instances, type, name, values) do |i, n, v|
                SpecieVariable[namer, i, type, v, name: n]
              end
            end
          end
        end

      end
    end
  end
end
