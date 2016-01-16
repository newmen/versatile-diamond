module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Contains methods for generate cpp expressions that calls advansed atom
        # methods of engine framework
        module AtomCppExpressions
          include Algorithm::Units::SpecieCppExpressions

        protected

          # Gets the code line or block with definition of specie variable
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the specie will be gotten
          # @param [UniqueSpecie] specie which will be defined
          # @yield appends after definition line or into definition block
          # @return [String] the definition of specie variable code
          def define_specie_code(atom, specie, &block)
            namer.assign_next(specie.var_name, specie) unless name_of(specie)
            if specie.many?(atom) || symmetric_unit?
              combine_specie_code(atom, specie, &block)
            elsif !name_of(specie)
              define_specie_line(atom, specie, &block)
            else
              block.call
            end
          end

        private

          # Gets a cpp code string that contains the call of method for check atom role
          # @param [Array] unchecked_atoms which role will be checked in code
          # @return [String] the string with cpp condition
          def check_roles_of(unchecked_atoms)
            chain('&&', unchecked_atoms.map(&method(:check_role_call)))
          end

          # Gets the code which checks the role of atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which role will be checked
          def check_role_call(atom)
            "#{name_of(atom)}->is(#{detect_role(atom)})"
          end

          # Gets the code line with definition of specie variable
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the specie will be gotten
          # @param [UniqueSpecie] specie which will be defined
          # @yield appends after definition line
          # @return [String] the definition of specie variable code
          def define_specie_line(atom, specie, &block)
            atom_call = spec_by_role_call(atom, specie)
            define_var_line("#{specie.class_name} *", specie, atom_call) + block.call
          end

          # Builds the complex composited block with definition and checking of specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the specie will be gotten
          # @param [UniqueSpecie] specie which will be defined
          # @yield inserts into definition block
          # @return [String] the definition of specie variable block
          def combine_specie_code(atom, specie, &block)
            inlay_procs(block) do |nest|
              initial_define_specie_code(atom, specie, &nest) unless name_of(specie)
              if specie.symmetric?(atom)
                nest[:each_symmetry_lambda, specie]
                nest[:same_atoms_condition, specie, atom] if name_of(atom)
              end
            end
          end

          # Nests the code which defines and possible checks the specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the specie will be gotten
          # @param [UniqueSpecie] specie which will be defined
          # @yield [Symbol, Array, Hash] nests the some method call
          def initial_define_specie_code(atom, specie, &nest)
            if specie.many?(atom)
              nest[:each_spec_by_role_lambda, specie, atom]
              nest[:check_defined_species_condition, specie]
            else
              nest[:define_specie_line, specie, atom]
            end
          end

          # Makes code string with calling of engine method that names specByRole
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the specie will be gotten
          # @param [UniqueSpecie] specie for which the code will be generated
          # @return [String] the string of cpp code with specByRole call
          def spec_by_role_call(atom, specie)
            if !specie.anchor?(atom)
              raise_ap_error(atom, specie, 'is not an anchor for using specie')
            elsif specie.many?(atom)
              raise_ap_error(atom, specie, 'can contain many species')
            else
              role = specie.role(atom)
              "#{name_of(atom)}->specByRole<#{specie.class_name}>(#{role})"
            end
          end

          # Gets a code which calls eachSpecByRole method of engine framework
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the species will be gotten
          # @param [UniqueSpecie] specie each instance of which will be iterated in
          #   passed atom
          # @yield should return cpp code string
          # @return [String] the code with each specie iteration
          def each_spec_by_role_lambda(atom, specie, &block)
            if specie.many?(atom)
              specie_class = specie.class_name
              method_name = "#{name_of(atom)}->eachSpecByRole<#{specie_class}>"
              method_args = [specie.role(atom)]
              closure_args = ['&']
              lambda_args = ["#{specie_class} *#{name_of(specie)}"]
              code_lambda(method_name, method_args, closure_args, lambda_args, &block)
            else
              raise_ap_error(atom, specie, 'cannot contain many species')
            end
          end

          # Throws the atom properties error
          # @raise [ArgumentError]
          def raise_ap_error(atom, specie, msg)
            ap = specie.properties_of(atom)
            raise ArgumentError, "Atom (#{ap}) #{msg} (#{specie.spec})"
          end
        end

      end
    end
  end
end
