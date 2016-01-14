module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Contains methods for generate cpp expressions that calls advansed atom
        # methods of engine framework
        module AtomCppExpressions
          include Modules::ProcsReducer
          include Algorithm::Units::SpecieCppExpressions

        protected

          # Gets the code line or block with definition of specie variable
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the specie will be gotten
          # @param [UniqueSpecie] specie which will be defined
          # @yield [String] appends after definition line or into definition block
          # @return [String] the definition of specie variable code
          def define_specie_code(atom, specie, &block)
            namer.assign_next(specie.var_name, specie)
            if specie.many?(atom) || symmetric_context?
              combine_specie_block(atom, specie, &block)
            else
              define_specie_line(atom, specie, &block)
            end
          end

        private

          # Checks that passed atom is symmetrical in passed specie
          # @param [SpecieInstance] specie which atoms will be checked
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is symmetric atom or not
          def symmetric_atom_of?(specie, atom)
            specie.symmetric?(atom)
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
          # @yield [String] appends after definition line
          # @return [String] the definition of specie variable code
          def define_specie_line(atom, specie, &block)
            atom_call = spec_by_role_call(atom, specie)
            define_var_line("#{specie.class_name} *", specie, atom_call) + block.call
          end

          # Builds the complex composited block with definition and checking of specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the specie will be gotten
          # @param [UniqueSpecie] specie which will be defined
          # @yield [String] inserts into definition block
          # @return [String] the definition of specie variable block
          def combine_specie_block(atom, specie, &block)
            procs = []
            add_proc = -> method_name, *args do
              procs << -> &prc { send(method_name, *args, &prc) }
            end

            atom_call =
              specie.many?(atom) ? :each_spec_by_role_lambda : :define_specie_line

            add_proc[atom_call, atom, specie]
            add_proc[:each_symmetry_lambda, specie] if symmetric_context?
            if symmetric_atom_of?(specie, atom)
              add_proc[:same_atom_condition, specie, atom]
            end

            reduce_procs(procs, &block)
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

          # @raise [ArgumentError]
          def raise_ap_error(atom, specie, msg)
            ap = specie.properties_of(atom)
            msg = "Atom (#{ap}) #{msg} (#{specie.spec})"
            raise ArgumentError, msg
          end
        end

      end
    end
  end
end