module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Providers base methods for units which calls engine framework
        # @abstract
        class GenerableUnit

          # @param [Expressions::VarsDictionary] dict
          def initialize(dict)
            @dict = dict
          end

        private

          attr_reader :dict

          # Selects the variables which were defined
          # @param [Array] instances for which the defined variables will be selected
          # @return [Array] the list of defined instances
          def select_defined(*instances)
            apply_var_to(:select, *instances)
          end

          # Rejects the variables which were defined
          # @param [Array] instances for which the defined variables will be rejected
          # @return [Array] the list of undefined variables
          def select_undefined(*instances)
            apply_var_to(:reject, *instances)
          end

          # Finds the defined variable
          # @param [Array] instances where first defined variable will be found
          # @return [Object] the defined variable or nil if no any defined
          def find_defined(*instances)
            apply_var_to(:find, *instances)
          end

          # Finds the undefined variable
          # @param [Array] instances where first undefined variable will be found
          # @return [Object] the undefined variable or nil if all are defined
          def find_undefined(*instances)
            select_undefined(*instances).first
          end

          # Checks that any variable in passed list are defined
          # @param [Array] instances which will be checked
          # @return [Boolean] is any variable defined or not
          def any_defined?(*instances)
            apply_var_to(:any?, *instances)
          end

          # Checks that all variables in passed list are defined
          # @param [Array] instances which will be checked
          # @return [Boolean] are all variables defined or not
          def all_defined?(*instances)
            apply_var_to(:all?, *instances)
          end

          # Applies method to list of variable with getting name function as block
          # @param [Symbol] method_name which will called for accumulate result from
          #   variables list
          # @param [Array] instances list which will be reduced
          # @return [Object] depends from using method
          def apply_var_to(method_name, *instances)
            method = dict.public_method(:var_of)
            star_to_array(*instances).public_send(method_name, &method)
          end

          # Safe converts passed variadic list of arguments to array instead the case
          # when argument just one and it is list already
          #
          # @param [Array] args which will be safe converted
          # @return [Array] the list of arguments as one array
          def star_to_array(*args)
            list = args.one? ? args.first : args
            if list.is_a?(Enumerable)
              list
            else
              raise ArgumentError, 'Array expected'
            end
          end
        end

      end
    end
  end
end
