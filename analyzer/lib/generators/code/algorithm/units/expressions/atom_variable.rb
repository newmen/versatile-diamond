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
              call('is', actual_role_value(specie))
            end
          end

          # @param [Array] species
          # @param [Core::Expression] body
          # @return [Core::Condition]
          def check_context(species, body)
            Core::Condition[not_found(species.first), body]
          end

          # @param [Instances::SpecieInstance] specie
          # @return [Core::OpNot]
          def not_found(specie)
            verify_anchor_of(specie) do
              actual = specie.actual
              method_name = actual.find_endpoint? ? 'hasRole' : 'checkAndFind'
              enum_name = Core::Constant[actual.enum_name]
              role = actual_role_value(specie)
              Core::OpNot[call(method_name, enum_name, role)]
            end
          end

          # @param [Array] defined_vars
          # @param [SpecieVariable] specie_var
          # @return [Core::OpCall]
          def each_specie_by_role(defined_vars, specie_var, body)
            specie_inst = specie_var.instance
            verify_anchor_of(specie_inst) do
              role = Core::Constant[specie_inst.source_role(instance)]
              iter_lambda = Core::Lambda[defined_vars, specie_var, body]
              specie_type = Core::ObjectType[specie_inst.original.class_name]
              call('eachSpecByRole', role, iter_lambda, template_args: [specie_type])
            end
          end

        private

          # @param [Instances::SpecieInstance] specie
          # @return [Core::Constant]
          def actual_role_value(specie)
            Core::Constant[specie.actual_role(instance)]
          end

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
