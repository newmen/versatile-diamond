module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Describes atoms array variable
        class AtomsArray < Core::Collection

          DEFAULT_NAME = Code::Specie::INTER_ATOM_NAME

          class << self
            # @param [NameRemember] namer
            # @param [Array] instances
            # @param [Array] values
            # @option [String] :name which will be pluralized
            # @return [AtomsArray]
            def [](namer, instances, values = nil, name: DEFAULT_NAME)
              super(namer, instances, AtomType[].ptr, name, values) do |i, n, v|
                AtomVariable[namer, i, v, name: n]
              end
            end
          end

          # @param [Array] species
          # @return [Core::Condition]
          def check_roles_in(species, body)
            Core::Condition[roles_in(species), body]
          end

        private

          # @param [Array] species
          # @return [Core::OpAnd]
          def roles_in(species)
            calls = pack_each_with(species).map { |i, s| i.role_in(s) }
            Core::OpAnd[*calls]
          end

          # @param [Array] species
          # @return [Array]
          def pack_each_with(species)
            items.map do |item|
              [item, species.find { |s| s.anchor?(item.instance) }]
            end
          end
        end

      end
    end
  end
end
