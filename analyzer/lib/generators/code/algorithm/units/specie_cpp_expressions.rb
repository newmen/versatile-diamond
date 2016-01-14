module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Contains methods for generate cpp expressions with using specie instances
        module SpecieCppExpressions
        private

          # Gets code string with call getting atom from specie
          # @param [UniqueSpecie] specie from which will get index of twin
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom of which will be used for get an index of it from specie
          # @return [String] code where atom getting from specie
          def atom_from_specie_call(specie, atom)
            index = specie.index(atom)
            if index
              "#{name_of(specie)}->atom(#{index})"
            else
              raise ArgumentError, "Undefined atom #{atom} for #{specie.spec}"
            end
          end

          # Gets a code which uses eachSymmetry method of engine framework
          # @param [UniqueSpecie] specie by variable name of which the target method
          #   will be called
          # @option [Boolean] :closure if true then lambda function closes to the scope
          # @yield should return cpp code string
          # @return [String] the code with symmetries iteration
          def each_symmetry_lambda(specie, closure: true, &block)
            if specie.original.symmetric?
              method_name = "#{name_of(specie)}->eachSymmetry"
              namer.erase(specie)
              namer.assign_next(specie.var_name, specie)
              closure_args = closure ? ['&'] : []
              lambda_args = ["#{specie_type} *#{name_of(specie)}"]
              code_lambda(method_name, [], closure_args, lambda_args, &block)
            else
              raise ArgumentError, "Specie #{specie.spec} is not symmetric"
            end
          end


          # Gets condition with checking that same atom of specie is passed atom
          # @param [UniqueSpecie] specie which same atom will be compared
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def same_atom_condition(specie, atom, &block)
            specie_call = atom_from_specie_call(specie, atom)
            code_condition("#{name_of(atom)} == #{specie_call}", &block)
          end
        end

      end
    end
  end
end
