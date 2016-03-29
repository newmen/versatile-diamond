module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents atom variable statement
        class AtomVariable < Core::Variable
          # @param [Instances::SpecieInstance] specie
          # @return [Core::OpCall]
          def role_in(specie)
            call('is', actual_role_in(specie))
          end

          # @param [Instances::SpecieInstance] specie
          # @return [Core::OpNot]
          def not_found(specie)
            verify_anchor_of(specie) do
              actual = specie.actual
              method_name = actual.find_endpoint? ? 'hasRole' : 'checkAndFind'
              enum_name = Core::Constant[actual.enum_name]
              role = actual_role_in(specie)
              Core::OpNot[call(method_name, enum_name, role)]
            end
          end

          # @param [Instances::SpecieInstance] specie
          # @return [Core::OpCall]
          def one_specie_by_role(specie)
            verify_anchor_of(specie) do
              role = source_role_in(specie)
              type = specie_type_of(specie)
              call('specByRole', role, template_args: [type])
            end
          end

          # @param [Array] defined_vars
          # @param [SpecieVariable] specie_var
          # @return [Core::OpCall]
          def all_species_by_role(defined_vars, specie_var, body)
            specie_inst = specie_var.instance
            verify_anchor_of(specie_inst) do
              role = source_role_in(specie_inst)
              type = specie_type_of(specie_inst)
              iter_lambda = Core::Lambda[defined_vars, specie_var, body]
              call('eachSpecByRole', role, iter_lambda, template_args: [type])
            end
          end

          # @param [Array] defined_vars
          # @param [SpeciesArray] species_arr
          # @return [Core::OpCall]
          def species_portion_by_role(defined_vars, species_arr, body)
            one_specie_inst = species_arr.items.first.instance
            verify_anchor_of(one_specie_inst) do
              role = source_role_in(one_specie_inst)
              type = specie_type_of(one_specie_inst)
              num = Core::Constant[species_arr.items.size]
              iter_lambda = Core::Lambda[defined_vars, species_arr, body]
              method_name = 'eachSpecsPortionByRole'
              call(method_name, role, num, iter_lambda, template_args: [type])
            end
          end

          # @param [AtomVariable] atom_var
          # @return [Core::OpCall]
          def has_bond_with(atom_var)
            call('hasBondWith', atom_var)
          end

          # @param [Array] defined_vars
          # @param [AtomVariable] nbr_var
          # @return [Core::OpCall]
          def iterate_amorph_nbrs(defined_vars, nbr_var, body)
            iter_lambda = Core::Lambda[defined_vars, nbr_var, body]
            call('eachAmorphNeighbour', iter_lambda)
          end

          # @param [Array] defined_vars
          # @param [AtomVariable] nbr_var
          # @return [Core::OpCall]
          def iterate_crystal_nbrs(defined_vars, nbr_var, body)
            iter_lambda = Core::Lambda[defined_vars, nbr_var, body]
            call('eachCrystalNeighbour', iter_lambda)
          end

        private

          # @param [Instances::SpecieInstance] specie
          # @return [Core::Constant]
          def actual_role_in(specie)
            Core::Constant[specie.actual_role(instance)]
          end

          # @param [Instances::SpecieInstance] specie
          # @return [Core::Constant]
          def source_role_in(specie)
            Core::Constant[specie.source_role(instance)]
          end

          # @param [Instances::SpecieInstance] specie
          # @return [Core::ObjectType]
          def specie_type_of(specie)
            Core::ObjectType[specie.original.class_name]
          end

          # @param [Instances::SpecieInstance] specie
          # @yield incorporating statement
          # @return [Core::Statement]
          def verify_anchor_of(specie, &block)
            if specie.anchor?(instance)
              block.call
            else
              raise ArgumentError, "#{code} is not anchor of #{specie.inspect}"
            end
          end
        end

      end
    end
  end
end
