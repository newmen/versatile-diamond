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
          # @param [String] type of iterable symmetric specie
          # @option [Boolean] :clojure_on_scope if true then lambda function closes
          #   to each external varaible of method where it using
          # @yield should return cpp code string
          # @return [String] the code with symmetries iteration
          def each_symmetry_lambda(specie, type, clojure_on_scope: true, &block)
            specie_var_name = namer.name_of(specie)
            method_name = "#{specie_var_name}->eachSymmetry"
            namer.erase(specie)

            namer.assign_next('specie', specie)
            specie_var_name = namer.name_of(specie)
            clojure_args = clojure_on_scope ? ['&'] : []
            lambda_args = ["#{type} *#{specie_var_name}"]

            code_lambda(method_name, [], clojure_args, lambda_args, &block)
          end
        end

      end
    end
  end
end
