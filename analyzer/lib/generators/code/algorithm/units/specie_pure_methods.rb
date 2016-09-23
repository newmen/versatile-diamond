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

          # @param [BasePureUnit] unit
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
              undefn_groups = select_undefined(species).group_by(&:original)
              defn_procs = undefn_groups.map { |_, sg| species_by_role_proc(sg) }
              call_procs(defn_procs, &block)
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
            dict.var_of(species).iterate(dict.make_iterator(:s), block.call)
          end

          def inspect
            sis = species.map(&:inspect)
            nas = nodes.uniq(&:atom)
            spops = nas.map(&:sub_properties).map(&:inspect)
            pkns = nas.map do |n|
              n.spec.spec.keyname(n.uniq_specie.send(:original_atom, n.atom))
            end
            ppops = nas.map(&:properties).map(&:inspect)
            ckns = nas.map do |n|
              ds = n.uniq_specie.spec
              ch = ds.instance_variable_get(:@child) || ds
              ch.spec.keyname(n.atom)
            end
            pkwps = pkns.zip(spops).map { |kp| kp.join(':') }
            ckwps = ckns.zip(ppops).map { |kp| kp.join(':') }
            bs = pkwps.zip(ckwps).map { |p, c| "(#{p})‡(#{c})" }
            "•[#{sis.join(' ')}] [#{bs.join(' ')}]•"
          end

        private

          # @param [Array] species_group which will be defined
          # @return [Proc] the all species definition construction with fiber notaion
          def species_by_role_proc(species_group)
            predefn_vars = dict.defined_vars # get before make inner nbr specie var
            specie_var = dict.make_specie_s(species_group)
            atom_var = dict.var_of(atoms)
            -> &block do
              atom_var.all_species_by_role(predefn_vars, specie_var, block.call)
            end
          end

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
