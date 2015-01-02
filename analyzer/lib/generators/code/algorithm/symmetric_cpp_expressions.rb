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
            specie_var_name = namer.name_of(specie)
            method_name = "#{specie_var_name}->eachSymmetry"
            namer.erase(specie)

            namer.assign_next('specie', specie)
            specie_var_name = namer.name_of(specie)
            closure_args = closure_on_scope ? ['&'] : []
            lambda_args = ["#{specie_type} *#{specie_var_name}"]

            code_lambda(method_name, [], closure_args, lambda_args, &block)
          end
        end

      end
    end
  end
end
