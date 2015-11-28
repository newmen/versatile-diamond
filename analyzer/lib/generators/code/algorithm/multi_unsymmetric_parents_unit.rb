module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from scope of unsymmetric parent species
        # @abstract
        class MultiUnsymmetricParentsUnit < MultiParentSpeciesUnit
          include MultiParentSpeciesCppExpressions
          include SymmetricCppExpressions

          # Also defines cache variable...
          def initialize(*)
            super
            @_using_specie_atoms = nil
          end

          # Gets a code with checking all same species from target atom
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          # @override
          def check_species(&block)
            procs = []
            procs << -> &prc { define_and_check_all_parents(&prc) }
            procs += symmetric_procs

            reduce_procs(procs) { define_avail_atoms_line + block.call }.call
          end

          def inspect
            "MUPSU:(#{inspect_target_atom_and_parents_names})"
          end

        private

          # Gets the list of atoms which uses in specie (like as anchors but a bit
          # more)
          #
          # @return [Array] the list of atoms which used in specie
          def using_specie_atoms
            @_using_specie_atoms ||= original_specie.using_atoms
          end

          # Gets list of procs where iterates symmetries of parent species
          # @return [Array] the list of procs
          def symmetric_procs
            other_atoms = using_specie_atoms - [target_atom]
            all_pwts = other_atoms.map { |a| parent_with_twin_for(a) }

            parent_species.each_with_object([]) do |parent, acc|
              twins = all_pwts.select { |pr, _| pr == parent }.map(&:last)
              if twins.any? { |a| parent.symmetric_atom?(a) }
                acc << -> &prc do
                  each_symmetry_lambda(parent, closure_on_scope: true, &prc)
                end
              end
            end
          end

          # Gets a cpp code that defines all anchors available from passed species
          # @param [Array] species from which defining atoms will be gotten
          # @return [String] the string of cpp code
          def define_avail_atoms_line
            atoms = using_specie_atoms - [target_atom]
            namer.assign(Specie::INTER_ATOM_NAME, atoms)

            pwts = using_specie_atoms.each_with_object([]) do |atom, acc|
              next if atom == target_atom
              acc << parent_with_twin_for(atom) { |pr, _| parent_species.include?(pr) }
            end

            grouped_pwts = pwts.group_by(&:first)
            grouped_twins = grouped_pwts.map { |pr, group| [pr, group.map(&:last)] }
            parent_to_uniq_twins =
              grouped_twins.each_with_object({}) do |(pr, ts), acc|
                acc[pr] = ts.uniq
              end

            parent_calls =
              parent_species.each_with_object([]) do |parent, acc|
                parent_to_uniq_twins[parent].each do |twin|
                  acc << atom_from_specie_call(parent, twin)
                end
              end

            define_var_line('Atom *', atoms, parent_calls)
          end
        end

      end
    end
  end
end
