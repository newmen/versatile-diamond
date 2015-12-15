module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains methods for generate cpp expressions where using symmetric
        # properties of specie
        module SymmetricCppExpressions
        private

          # Gets a code which uses eachSymmetry method of engine framework
          # @param [UniqueSpecie] specie by variable name of which the target method
          #   will be called
          # @option [Boolean] :closure_on_scope if true then lambda function closes
          #   to each external varaible of method where it using
          # @yield should return cpp code string
          # @return [String] the code with symmetries iteration
          def each_symmetry_lambda(specie, closure_on_scope: true, &block)
            method_name = "#{name_of(specie)}->eachSymmetry"
            namer.erase(specie)
            namer.assign_next(Specie::INTER_SPECIE_NAME, specie)
            closure_args = closure_on_scope ? ['&'] : []
            lambda_args = ["#{specie_type} *#{name_of(specie)}"]

            code_lambda(method_name, [], closure_args, lambda_args, &block)
          end

          # Gets cpp code with symmetric species iteration and checking that passed
          # atom is equal to atom from symmetric specie
          #
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   target_atom which name will be used for method call
          # @param [UniqueSpecie] specie which symmetries will be iterated
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   checking_atom which will be checked
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def checked_symmetries_lambda(target_atom, specie, checking_atom, &block)
            unb_method = SymmetricCppExpressions.instance_method(:each_symmetry_lambda)
            unb_method.bind(self).call(specie) do
              symmetric_atom_condition(target_atom, specie, checking_atom, &block)
            end
          end

          # Gets condition with checking that symmetric atom of specie is passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   target_atom which name will be used for method call
          # @param [UniqueSpecie] specie which symmetric atom will be compared
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   checking_atom which will be checked
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def symmetric_atom_condition(target_atom, specie, checking_atom, &block)
            unb_method = SpecieCppExpressions.instance_method(:atom_from_specie_call)
            specie_call = unb_method.bind(self).call(specie, checking_atom)
            code_condition("#{name_of(target_atom)} == #{specie_call}", &block)
          end
        end

      end
    end
  end
end
