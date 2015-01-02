module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains common methods for generate cpp expressions
        module CommonCppExpressions

          TAB_SIZE = 4 # always so for cpp

        private

          # Adds spaces (like one tab size) before passed string
          # @param [String] code_str the string before which spaces will be added
          # @return [String] the string with spaces before
          def add_prefix_spaces(code_str)
            "#{' ' * TAB_SIZE}#{code_str}"
          end

          # Increases spaces to one more tab before each line
          # @param [String] code_str the code with several lines
          # @return [String] code lines with added spaces before each line
          def increase_spaces(code_str)
            code_str.split("\n").map(&method(:add_prefix_spaces)).join("\n") + "\n"
          end

          # Inserts spaces before and inserts new line character after passed string
          # @param [String] code_str the wrapping string with cpp code
          # @param [String] the wrapped string with spaces and new line character
          def code_line(code_str)
            "#{add_prefix_spaces(code_str)}\n"
          end

          # Gets a code with cpp condition block
          # @param [String] condition_str the cpp code string with some condition
          # @param [String] else_prefix the prefix which places before `if` keyword
          # @yield should return cpp code with several lines which will placed into
          #   condition block
          # @return [String] the code with condition
          def code_condition(condition_str, else_prefix = '', &block)
            code_line("#{else_prefix}if (#{condition_str})") +
              code_line('{') +
              increase_spaces(block.call) +
              code_line('}')
          end

          # Gets a code with cpp lambda block
          # @param [String] method_name the name of engine framework method which have
          #   lambda as last argument
          # @param [Array] method_args the typed arguments of method call
          # @param [Array] closure_args the arguments which passed to lambda
          # @param [Array] lambda_args the typed arguments of lambda call
          # @yield should return cpp code with several lines which will be plased in
          #   lambda body
          # @return [String] the code with method call
          def code_lambda(method_name, method_args, closure_args, lambda_args, &block)
            separator = ', '
            closure_args_str = closure_args.join(separator)
            lambda_args_str = lambda_args.join(separator)

            lambda_head = "[#{closure_args_str}](#{lambda_args_str})"
            args_wo_lambda_body = (method_args + [lambda_head]).join(separator)

            code_line("#{method_name}(#{args_wo_lambda_body} {") +
              increase_spaces(block.call) +
              code_line('});')
          end

          # Gets cpp code line with defined variable
          # @param [String] type is the type of defining variable
          # @param [Array | Object] vars the variable which will be translated to cpp
          #   code
          # @param [Array | Object] values is the value(s) for defining variable
          # @return [String] cpp code line
          def define_var_line(type, vars, values)
            vars_is_array = vars.is_a?(Array) && vars.size > 1
            values_is_array = values.is_a?(Array) && values.size > 1
            if values_is_array && (!vars_is_array || vars.size != values.size)
              raise 'Incorrect number of variables for number of values'
            end

            var_name = namer.name_of(vars)
            value_str = values.is_a?(Array) ? values.join(', ') : values

            if vars_is_array && values_is_array
              var_name = "#{var_name}[#{vars.size}]"
              value_str = "{ #{value_str} }"
            end

            code_line("#{correct(type)}#{var_name} = #{value_str};")
          end

          # Inserts the space after type if it is need
          # @param [String] type the checkable and correctable cpp type
          # @return [String] corrected type of variable
          def correct(type)
            last_char = type[-1]
            last_char == '*' || last_char == ' ' ? type : "#{type} "
          end

          # Makes a condition which will be placed to cpp code template
          # @param [Array] items which zipped with variable names and iterates by block
          # @param [String] operator which use for combine condition
          # @yield [String, Object] the block should returns cpp code method call
          # @return [String] the cpp code string for condition in template
          def combine_condition(items, operator, &block)
            names = items.map { |item| namer.name_of(item) }
            names.zip(items).map(&block).join(" #{operator} ")
          end
        end

      end
    end
  end
end
