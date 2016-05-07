module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides methods for specie pure units
        module SpeciePureMethods
          include Algorithm::Units::SpecieAbstractType

          def define_atom_anchor!
            kwargs = { name: Code::Specie::ANCHOR_ATOM_NAME, next_name: false }
            dict.make_atom_s(atoms.first, **kwargs)
          end

          def define_specie_anchor!
            kwargs = { name: Code::Specie::ANCHOR_SPECIE_NAME, next_name: false }
            dict.make_specie_s(species.first, **kwargs)
          end

          # @return [Boolean]
          def checkable?
            !(species.all?(&:none?) || all_defined?(anchored_species))
          end

          # @return [Boolean]
          def neighbour?(unit)
            selector_proc = unit.species.public_method(:include?)
            same_species = anchored_species.select(&selector_proc)
            same_species.empty? || same_species.all?(&:none?)
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def check_different_atoms_roles(&block)
            checking_nodes = incoming_nodes.dup
            if checking_nodes.empty?
              block.call
            else
              check_atoms_roles(checking_nodes.map(&:atom), &block)
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::OpCall]
          def iterate_species_by_role(&block)
            if atoms.one?
              predefn_vars = dict.defined_vars # get before make inner nbr specie var
              specie_var = dict.make_specie_s(select_undefined(species))
              atom_var = dict.var_of(atoms)
              atom_var.all_species_by_role(predefn_vars, specie_var, block.call)
            else
              raise 'Species iteration by role can occur from just one atom'
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_portions_of_similar_species(&block)
            if atoms.one?
              predefn_vars = dict.defined_vars # get before make inner nbr species var
              species_var = dict.make_specie_s(select_undefined(species))
              atom_var = dict.var_of(atoms)
              atom_var.species_portion_by_role(predefn_vars, species_var, block.call)
            else
              raise 'Species portion iteration can occur from just one atom'
            end
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def iterate_species_by_loop(&block)
            dict.var_of(species).each(block.call)
          end

        private

          # @return [Array]
          def incoming_nodes
            nodes.reject(&:coincide?).select do |n|
              dict.var_of(n.uniq_specie) &&
                (dict.var_of(n.atom) || !n.properties.include?(n.sub_properties))
            end
          end
        end

      end
    end
  end
end
