module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Describes atoms array variable
        class AtomsArray < Core::Collection
          # @param [Array] species
          # @param [Core::Expression] body
          # @return [Core::Condition]
          def check_roles_in(species, body)
            Core::Condition[roles_in(species), body]
          end

          # @param [Array] species
          # @param [Core::Expression] body
          # @return [Core::Condition]
          def check_context(species, body)
            Core::Condition[founds_in(species), body]
          end

        private

          # @param [Array] species
          # @return [Core::OpAnd]
          def roles_in(species)
            Core::OpAnd[*pack_each_with(species).map { |i, s| i.role_in(s) }]
          end

          # @param [Array] species
          # @return [Core::OpAnd]
          def founds_in(species)
            Core::OpOr[*pack_each_with(species).map { |i, s| i.found_in(s) }]
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
