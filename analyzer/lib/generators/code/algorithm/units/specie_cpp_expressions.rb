module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Contains methods for generate cpp expressions with using specie instances
        module SpecieCppExpressions
        private

          # Assigns the name of anchor specie variable
          def assign_anchor_specie_name!
            namer.assign(Specie::ANCHOR_SPECIE_NAME, uniq_species)
          end

          # Gets code string with call getting atom from specie
          # @param [UniqueSpecie] specie from which will get index of twin
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom of which will be used for get an index of it from specie
          # @return [String] code where atom getting from specie
          def atom_from_specie_call(specie, atom)
            "#{name_of(specie)}->atom(#{specie.index(atom)})"
          end

          # Defines passed atoms by passed block
          # @param [Array] undefined_atoms which will be defined
          # @param [Array] values which will be applied to atoms variable
          # @return [String] the code line with atoms definition
          def define_atoms_line(undefined_atoms, values)
            namer.assign_next(Specie::ANCHOR_ATOM_NAME, undefined_atoms)
            define_var_line('Atom *', undefined_atoms, values)
          end

          # Renames and defines the internal atoms with next atom(s) variable name
          # @param [Array] old_accesses which was avail for internal atoms
          # @return [String] the code line with definition renamed atoms
          def define_renamed_atoms_line(old_accesses)
            namer.erase(uniq_atoms)
            define_atoms_line(uniq_atoms, old_accesses)
          end

          # Gets the list of defined atom names or undefined atoms calls
          # @param [Array] checking_atoms for which the accesses will be gotten
          # @return [Array] the list of accesses to atoms
          def atom_accesses_to(checking_atoms)
            names_or(checking_atoms) { |atom| atom_from_specie_call(specie, atom) }
          end

          # Defines all available atoms
          # @option [Array] epx passes to next block
          # @yield should return cpp code
          # @return [String] the definition of all atoms variable block
          def define_all_atoms_code(**epx, &block)
            if all_defined?(uniq_atoms)
              block.call
            else
              inlay_procs(block) do |nest|
                uniq_species.each do |specie|
                  nest_specie_checking(specie, **epx, &nest)
                end
              end
            end
          end

          # Nests the definition of the passed specie
          # @param [SpecieInstance] specie which which will be defined
          # @option [Array] epx passes to next block
          # @yield [Symbol, Array, Hash] nests the some method call
          def nest_specie_checking(specie, **epx, &nest)
            unless name_of(specie)
              avail_anchor_atom = avail_anchor_atom_of(specie)
              nest[:define_specie_code, avail_anchor_atom, specie] if avail_anchor_atom
            end
            nest[:define_specie_atoms_code, specie, **epx]
          end

          # Defines atoms of passed specie
          # @param [SpecieInstance] specie which atoms will be defined
          # @yield should return cpp code
          # @return [String] the definition of anchor atoms variable block
          def define_specie_atoms_code(specie, **epx, &block)
            checking_atoms = symmetric_atoms_of(specie)
            if checking_atoms.empty?
              define_undefined_specie_atoms_code(specie, **epx, &block)
            else
              define_symmetric_specie_atoms_code(specie, checking_atoms, **epx, &block)
            end
          end

          # Defines symmetric atoms of passed specie
          # @param [SpecieInstance] specie which atoms will be defined
          # @option [Array] epx passes to next block
          # @yield should return cpp code
          # @param [Array] checking_atoms which will be compared with atoms of specie
          # @return [String] the definition of symmetric atoms variable block
          def define_symmetric_specie_atoms_code(specie, checking_atoms, **epx, &block)
            each_symmetry_lambda(specie) do
              define_undefined_specie_atoms_code(specie, **epx, &block)
            end
          end

          # Defines undefined atoms of passed specie
          # @param [SpecieInstance] specie which atoms will be defined
          # @option [Array] epx passes to next block
          # @yield should return cpp code
          # @return [String] the definition of undefined atoms variable block
          def define_undefined_specie_atoms_code(specie, **epx, &block)
            undefined_atoms = select_undefined(atoms_of(specie))
            if undefined_atoms.empty?
              block.call
            else
              calls = undefined_atoms.map { |a| atom_from_specie_call(specie, a) }
              define_atoms_line(undefined_atoms, calls) +
                check_roles_condition(undefined_atoms, &block)
            end
          end

          # Gets a code which uses eachSymmetry method of engine framework
          # @param [UniqueSpecie] specie by variable name of which the target method
          #   will be called
          # @option [Boolean] :closure if true then lambda function closes to the scope
          # @yield should return cpp code string
          # @return [String] the code with symmetries iteration
          def each_symmetry_lambda(specie, closure: true, &block)
            checking_atoms = symmetric_atoms_of(specie)
            if checking_atoms.empty?
              block.call
            else
              method_name = "#{name_of(specie)}->eachSymmetry"
              namer.erase(specie)
              namer.assign_next(specie.var_name, specie)
              closure_args = closure ? ['&'] : []
              lambda_args = ["#{specie_type} *#{name_of(specie)}"]
              code_lambda(method_name, [], closure_args, lambda_args) do
                same_atoms_condition(specie, checking_atoms, &block)
              end
            end
          end

          # Gets condition checking that atoms of specie are equal to passed atom
          # @param [UniqueSpecie] specie which atoms will be compared
          # @param [Array] checking_atoms which will be checked in specie
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def same_atoms_condition(specie, checking_atoms, &block)
            defined_atoms = select_defined(checking_atoms)
            if defined_atoms.empty?
              block.call
            else
              instances_condition(:compare_same_atoms, specie, checking_atoms, &block)
            end
          end

          # Checks all passed atoms in passed specie
          # @param [UniqueSpecie] specie which same atoms will be compared
          # @param [Array] checking_atoms which will be compared with atoms of specie
          # @return [String] the string with cpp code
          def compare_same_atoms(specie, checking_atoms)
            combine_condition(checking_atoms, '&&') do |var, atom|
              "#{var} == #{atom_from_specie_call(specie, atom)}"
            end
          end

          # Gets the code with check that passed specie is not another defined specie
          # @param [UniqueSpecie] specie which will be compared with defined species
          # @yield should return cpp code string which will do if specie is a new
          # @return [String] the code with condition block
          def check_defined_species_condition(specie, &block)
            similar_species = same_defined_species(specie)
            if similar_species.empty?(specie)
              block.call
            else
              diff_species_condition(specie, similar_species, &block)
            end
          end

          # Gets condition checking that similar defined species are not same as passed
          # @param [UniqueSpecie] specie which will be compared with each defined
          # @param [Array] similar_species with which will be compared the specie
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def diff_species_condition(specie, similar_species, &block)
            instances_condition(:compare_diff_species, specie, similar_species, &block)
          end

          # Checks all passed atoms in passed specie
          # @param [UniqueSpecie] specie which will be compared with each defined
          # @param [Array] similar_species with which will be compared the specie
          # @return [String] the string with cpp code
          def compare_diff_species(specie, similar_species)
            combine_condition(similar_species, '&&') do |var, defined_specie|
              "#{var} != #{name_of(defined_specie)}"
            end
          end
        end

      end
    end
  end
end
