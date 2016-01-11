module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Contains methods for generate cpp expressions that calls advansed atom
        # methods of engine framework
        module AtomCppExpressions
        protected

          # Gets the code line with definition of specie variable
          # @return [String] the definition of specie variable
          def define_specie_line(specie, atom)
            namer.assign_next(Specie::INTER_SPECIE_NAME, specie)
            define_var_line("#{specie.class_name} *", specie, spec_by_atom_call(atom))
          end

        private

          # Makes code string with calling of engine method that names specByRole
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   target_atom which name will be used for method call
          # @param [UniqueSpecie] specie for which the code will be generated
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   getting_atom of which will be used for get a role of atom in specie
          # @return [String] the string of cpp code with specByRole call
          def spec_by_role_call(target_atom, specie, getting_atom)
            unless specie.proxy_spec.anchors.include?(getting_atom)
              ap = atom_properties(specie.proxy_spec, getting_atom)
              msg = "Atom (#{ap}) is not an anchor for using specie (#{specie.spec})"
              raise ArgumentError, msg
            end

            if generator.many_times?(specie.proxy_spec, getting_atom)
              ap = atom_properties(specie.proxy_spec, getting_atom)
              msg = "Atom (#{ap}) can contain many species (#{specie.spec})"
              raise ArgumentError, msg
            end

            role = specie.role(getting_atom)
            "#{name_of(target_atom)}->specByRole<#{specie.class_name}>(#{role})"
          end

          # Gets a code which calls eachSpecByRole method of engine framework
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   target_atom which name will be used for method call
          # @param [UniqueSpecie] specie each instance of which will be iterated in
          #   passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   getting_atom of which will be used for get a role of atom in specie
          # @yield should return cpp code string
          # @return [String] the code with each specie iteration
          def each_spec_by_role_lambda(target_atom, specie, getting_atom, &block)
            unless generator.many_times?(specie.proxy_spec, getting_atom)
              ap = atom_properties(specie.proxy_spec, getting_atom)
              msg = "Atom (#{ap}) cannot contain many species (#{specie.spec})"
              raise ArgumentError, msg
            end

            specie_class = specie.class_name
            method_name = "#{name_of(target_atom)}->eachSpecByRole<#{specie_class}>"
            method_args = [specie.role(getting_atom)]
            closure_args = ['&']
            lambda_args = ["#{specie_class} *#{name_of(specie)}"]

            code_lambda(method_name, method_args, closure_args, lambda_args, &block)
          end
        end

      end
    end
  end
end
