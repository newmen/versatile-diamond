module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code that depends from scope of same unsymmetric parent
        # species
        class MultiSameUnsymmetricParentsUnit < MultiUnsymmetricParentsUnit

          def inspect
            "MSUPSU:(#{inspect_target_atom_and_parents_names})"
          end

        private

          # Collects and reduces procs each of which defines parent and checks it
          # @yield should return cpp code string for final condition body
          # @return [String] the string with cpp code
          def define_and_check_all_parents(&block)
            parent_species.each do |parent_specie|
              namer.assign_next(parent_specie.var_name, parent_specie)
            end

            iterated = []
            procs = parent_species.each_with_object([]) do |parent, acc|
              acc << -> &prc { each_spec_by_role_lambda(parent, &prc) }

              prev_prs_num = iterated.size
              iterated << parent
              next if prev_prs_num == 0

              opr = [parent]
              pairs = (iterated - opr).zip(opr * prev_prs_num)
              names = pairs.map(&method(:names_for))
              conds_str = names.map { |pair| pair.join(' != ') }.join(' && ')
              acc << -> &prc { code_condition(conds_str, &prc) }
            end

            reduce_procs(procs, &block).call
          end
        end

      end
    end
  end
end
