module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides logic for units which uses when reaction find algorithm builds
        module ReactantBehavior

          # Assigns the name for internal reactant specie, that it could be used when
          # the algorithm generates
          def first_assign!
            if whole?
              assign_anchor_specie_name!
            else
              raise 'Incorrect starting point to reaction find algorithm'
            end
          end

          # Prepares reactant instance for creation
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def check_symmetries(&block)
            if whole? || mono? || !symmetric_unit?
              define_all_atoms_code(&block)
            else
              loop_symmetry_lambda(symmetric_atoms, &block)
            end
          end

        private

          # Gets a code with for loop
          # @param [Array] target_atoms which will be cyclic iterates in loop
          # @yield is the body of for loop
          # @return [String] the code with passed atoms iteration
          def loop_symmetry_lambda(target_atoms, &block)
            code_for_loop('uint', 'ae', target_atoms.size) do |i|
              if target_atoms.size == 2 && namer.full_array?(target_atoms)
                atoms_var_name = name_of(target_atoms)
                namer.reassign("#{atoms_var_name}[#{i}]", target_atoms.first)
                namer.reassign("#{atoms_var_name}[1-#{i}]", target_atoms.last)
              else
                # TODO: maybe need to redefine atoms as separated array before loop
                # statement in the case when atoms are not "full array"
                raise 'Can not figure out the next names of atoms variables'
              end
              block.call
            end
          end
        end

      end
    end
  end
end
