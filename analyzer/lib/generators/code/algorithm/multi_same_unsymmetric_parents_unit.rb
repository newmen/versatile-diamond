module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from scope of same unsymmetric parent
        # species
        class MultiSameUnsymmetricParentsUnit < MultiUnsymmetricParentsUnit
          include SymmetricCppExpressions

          def inspect
            "MTUPSU:(#{inspect_target_atom_and_parents_names})"
          end

        private

          # Collects and reduces procs each of which defines parent and checks it
          # @yield should return cpp code string for final condition body
          # @return [String] the string with cpp code
          def define_and_check_all_parents(&block)
            parent_species.each { |pr| namer.assign_next('specie', pr) }

            iterated = []
            procs = parent_species.each_with_object([]) do |parent, acc|
              acc << -> &prc { each_spec_by_role_lambda(parent, &prc) }

              prev_prs_num = iterated.size
              iterated << parent
              next if prev_prs_num == 0

              opr = [parent]
              pairs = (iterated - opr).zip(opr * prev_prs_num)
              names = pairs.map { |pair| pair.map(&method(:name_of)) }
              conds_str = names.map { |pair| pair.join(' != ') }.join(' && ')
              acc << -> &prc { code_condition(conds_str, &prc) }
            end

            reduce_procs(procs + symmetric_procs, &block).call
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
        end

      end
    end
  end
end
