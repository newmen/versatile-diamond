module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Providers base methods for units which calls engine framework
        # @abstract
        class GenerableUnit
          include CommonCppExpressions
          include AtomCppExpressions
          extend Forwardable

          # Initializes the creator
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          def initialize(generator, namer)
            @generator = generator
            @namer = namer
          end

        private

          attr_reader :generator, :namer
          def_delegator :namer, :name_of

          # Gets the list of names or result of block call for each variable from
          # passed list
          #
          # @param [Array] variables for which items the calling values
          # @yield [Object] uses if the name of correspond variable is not defined
          # @return [Array] the list of calls for use it in code
          def names_or(variables, &block)
            variables.map { |variable| name_of(variable) || block[variable] }
          end

          # Gets the list of names for each variable from passed list
          # @param [Array] variables for which items the names will be gotten
          # @return [Array] the list of defined names (some name can be nil if was not
          #   defined for correspond variable)
          def names_for(*variables)
            apply_names_to(:map, *variables)
          end

          # Selects the variables which were defined
          # @param [Array] variables for which the defined variables will be selected
          # @return [Array] the list of defined variables
          def select_defined(*variables)
            apply_names_to(:select, *variables)
          end

          # Rejects the variables which were defined
          # @param [Array] variables for which the defined variables will be rejected
          # @return [Array] the list of undefined variables
          def select_undefined(*variables)
            apply_names_to(:reject, *variables)
          end

          # Finds the defined variable
          # @param [Array] variables where first defined variable will be found
          # @return [Object] the defined variable or nil if no any defined
          def find_defined(*variables)
            apply_names_to(:find, *variables)
          end

          # Finds the undefined variable
          # @param [Array] variables where first undefined variable will be found
          # @return [Object] the undefined variable or nil if all are defined
          def find_undefined(*variables)
            select_undefined(*variables).first
          end

          # Checks that any variable in passed list are defined
          # @param [Array] variables which will be checked
          # @return [Boolean] is any variable defined or not
          def any_defined?(*variables)
            apply_names_to(:any?, *variables)
          end

          # Checks that all variables in passed list are defined
          # @param [Array] variables which will be checked
          # @return [Boolean] are all variables defined or not
          def all_defined?(*variables)
            apply_names_to(:all?, *variables)
          end

          # Applies method to list of variable with getting name function as block
          # @param [Symbol] method_name which will called for accumulate result from
          #   variables list
          # @param [Array] variables list which will be reduced
          # @return [Object] depends from using method
          def apply_names_to(method_name, *variables)
            list = variables.size == 1 ? variables.last : variables
            fail 'Array expected' unless variables.is_a?(Enumerable)
            list.public_send(method_name, &method(:name_of))
          end
        end

      end
    end
  end
end
