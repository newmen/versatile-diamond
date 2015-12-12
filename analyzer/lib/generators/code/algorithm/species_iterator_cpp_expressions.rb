module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains methods for iterate species from some atom
        module SpeciesIteratorCppExpressions
        private

          # Gets a code which calls eachSpecByRole method of engine framework
          # @param [UniqueSpecie] specie each instance of which will be iterated in
          #   passed atom
          # @yield should return cpp code string
          # @return [String] the code with each specie iteration
          def each_spec_by_role_lambda(atom, specie, &block)
            specie_class = specie.class_name
            method_name = "#{target_atom_var_name}->eachSpecByRole<#{specie_class}>"
            method_args = [specie.role(atom)]
            closure_args = ['&']
            lambda_args = ["#{specie_class} *#{name_of(specie)}"]

            code_lambda(method_name, method_args, closure_args, lambda_args, &block)
          end
        end

      end
    end
  end
end
