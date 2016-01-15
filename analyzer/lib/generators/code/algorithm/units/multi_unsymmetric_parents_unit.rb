module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code that depends from scope of unsymmetric parent species
        # @abstract
        class MultiUnsymmetricParentsUnit < MultiParentSpeciesUnit

          # Also initiates internal caches
          def initialize(*)
            super
            @_other_atoms = nil
          end

          # Gets a code with checking all same species from target atom
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          # @override
          def check_species(&block)
            deepest_block = -> { define_avail_atoms_line + block.call }
            inlay_procs(deepest_block) do |nest|
              nest[:define_and_check_all_parents]
              all_pwts = other_atoms.map(&method(:parent_with_twin_for))
              parent_species.each do |parent|
                same_pwts = all_pwts.select(pwt_by(parent))
                if same_pwts.any?(&method(:symmetric_atom?))
                  nest[:each_symmetry_lambda, parent, closure: true]
                end
              end
            end
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
            original_spec.anchors
          end

          # Gets a list of atoms wihtout target atom
          # @return [Array] the list of another specie atoms
          def other_atoms
            @_other_atoms ||= using_specie_atoms - [target_atom]
          end

          # Gets a cpp code that defines all anchors available from passed species
          # @param [Array] species from which defining atoms will be gotten
          # @return [String] the string of cpp code
          def define_avail_atoms_line
            namer.assign(Specie::INTER_ATOM_NAME, other_atoms)

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
                  acc << atom_from_parent_call(parent, twin)
                end
              end

            define_var_line('Atom *', other_atoms, parent_calls)
          end
        end

      end
    end
  end
end
