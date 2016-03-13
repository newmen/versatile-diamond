module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents atom variable statement
        class AtomVariable < Core::Variable
          # @param [Array] species
          # @param [Core::Expression] body
          # @return [Core::Condition]
          def check_roles_in(species, body)
            Core::Condition[role_in(species.first), body]
          end

          # @param [Instances::SpecieInstance] specie
          # @return [Core::OpCall]
          def role_in(specie)
            verify_anchor_of(specie) do
              role = Constant[specie.actual_role(instance)]
              call('is', role)
            end
          end

          # @param [Array] species
          # @param [Core::Expression] body
          # @return [Core::Condition]
          def check_context(species, body)
            Core::Condition[found_in(species.first), body]
          end

          # @param [Array] species
          # @return [Core::OpCall]
          def found_in(specie)
            verify_anchor_of(specie) do
              actual = specie.actual
              method_name = actual.find_endpoint? ? 'hasRole' : 'checkAndFind'
              enum_name = Core::Constant[actual.enum_name]
              role = Core::Constant[specie.actual_role(instance)]
              Core::OpNot[call(method_name, enum_name, role)]
            end
          end

        private

          # @param [Instances::SpecieInstance] specie
          # @yield incorporating statement
          # @return [Core::Statement]
          def verify_anchor_of(specie, &block)
            if specie.anchor?(instance)
              block.call
            else
              raise ArgumentError, "#{code} is not anchor of #{specie}"
            end
          end
        end

      end
    end
  end
end
