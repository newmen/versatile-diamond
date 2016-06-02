module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents atom variable statement
        class AtomVariable < Core::Variable
          include LatticePositionReference

          # @param [Instances::SpecieInstance] specie
          # @return [Core::OpCall]
          def role_in(specie)
            call('is', actual_role_in(specie))
          end

          # @param [Integer] index
          # @return [Core::OpCall]
          def role_as(index)
            call('is', Core::Constant[index])
          end

          # @param [Instances::SpecieInstance] specie
          # @return [Core::OpNot]
          def not_found(specie)
            verify_anchor_of(specie, check_method: :actual_anchor?) do
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

          # @param [Array] defined_vars
          # @param [AtomVariable] nbr_var
          # @param [Core::ObjectType] lattice
          # @param [Hash] rel_params
          # @return [Core::FunctionCall]
          def iterate_over_lattice(defined_vars, nbr_var, lattice, rel_params, body)
            if instance.lattice
              ref = ref_rel(lattice, rel_params)
              iter_lambda = Core::Lambda[defined_vars, nbr_var, body]
              Core::FunctionCall['eachNeighbour', self, ref, iter_lambda]
            else
              raise NoMethodError, "Atom haven't lattice"
            end
          end

          # @param [Array] defined_vars
          # @param [AtomsArray] nbrs_arr
          # @param [Core::ObjectType] lattice
          # @param [Hash] rel_params
          # @return [Core::FunctionCall]
          def all_crystal_nbrs(defined_vars, nbrs_arr, lattice, rel_params, body)
            ref = ref_rel(lattice, rel_params)
            iter_lambda = Core::Lambda[defined_vars, nbrs_arr, body]
            Core::FunctionCall['allNeighbours', self, ref, iter_lambda]
          end

          # @return [Core::FunctionCall]
          def crystal
            if instance.lattice
              Core::FunctionCall['crystalBy', self]
            else
              raise NoMethodError, 'Atom not belongs to crystal'
            end
          end

          # @param [AtomVariable] other
          # @param [Core::ObjectType] lattice
          # @param [Hash] rel_params
          # @return [Core::FunctionCall]
          def coords_with(other, lattice, rel_params)
            lattice_call_at(lattice, rel_params, self, other)
          end

          # @return [Core::FunctionCall]
          def insert_to_amorph
            HandbookClass[].insert_amorph_atom(self)
          end

          # @param [Core::FunctionCall] crystal_call
          # @param [Core::FunctionCall] coords_call
          # @return [Core::FunctionCall]
          def insert_to_crystal(crystal_call, coords_call)
            crystal_call.call('insert', self, coords_call)
          end

          # @return [Core::FunctionCall]
          def erase_from_amorph
            HandbookClass[].erase_amorph_atom(self)
          end

          # @return [Core::FunctionCall]
          def erase_from_crystal
            if instance.lattice
              call('lattice').call('crystal').call('erase', self)
            else
              raise NoMethodError, 'Atom without lattice cannot be erased from crystal'
            end
          end

          # @param [Integer] delta
          # @return [Core::Statement]
          def recharge(delta)
            if delta == 0
              raise ArgumentError, 'Cannot recharge with 0 delta'
            elsif delta.abs > instance.valence
              raise ArgumentError, 'Too large delta for atom recharging'
            else
              method_name = delta > 0 ? 'activate' : 'deactivate'
              ([call(method_name)] * delta.abs).reduce(:+)
            end
          end

          # @param [AtomVariable] other
          # @return [Core::FunctionCall]
          def bond_with(other)
            call('bondWith', other)
          end

          # @param [AtomVariable] other
          # @return [Core::FunctionCall]
          def unbond_from(other)
            call('unbondFrom', other)
          end

          # @param [Integer] index
          # @return [Core::OpCall]
          def change_role(index)
            call('changeType', Core::Constant[index])
          end

          # @return [Core::FunctionCall]
          def mark_to_remove
            HandbookClass[].mark_removing_atom(self)
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
          def verify_anchor_of(specie, check_method: :anchor?, &block)
            if specie.public_send(check_method, instance)
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
