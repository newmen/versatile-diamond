module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Contains common methods for generate cpp expressions
        module CommonCppExpressions

          TAB_SIZE = 4 # always so for cpp
          PREFIX_SPACES = (' ' * TAB_SIZE).freeze

        private

          # Adds spaces (like one tab size) before passed string
          # @param [String] code_str the string before which spaces will be added
          # @return [String] the string with spaces before
          def add_prefix_spaces(code_str)
            "#{PREFIX_SPACES}#{code_str}"
          end

          # Shifts the passed code to one indent
          # @param [String] code_str which will be shifted
          # @return [String] the shifted cpp code
          def shift_code(code_str)
            code_str.split("\n").map(&method(:add_prefix_spaces)).join("\n")
          end

          # Inserts spaces before and inserts new line character after passed string
          # @param [String] code_str the wrapping string with cpp code
          # @param [String] the wrapped string with spaces and new line character
          def code_line(code_str)
            shift_code(code_str) + "\n"
          end

          # Transforms all passed string to sequental list of cpp code lines
          # @param [Array] code_strs the list of code units which will be transormed
          # @return [String] the scope of cpp code lines
          def code_lines(*code_strs)
            code_strs.map(&method(:code_line)).join
          end

          # Gets the code line with assert passed expression statement
          # @param [String] expr which will be asserted
          # @return [String] the cpp code line with assert expression
          def code_assert(expr)
            code_line("assert(#{expr});")
          end

          # Gets a code with cpp condition block
          # @param [String] condition_str the cpp code string with some condition
          # @option [Boolean] :use_else_prefix flag which identifies that before `if`
          #   keyword the `else ` prefix should be used
          # @yield should return cpp code with several lines which will placed into
          #   condition block
          # @return [String] the code with condition
          def code_condition(condition_str = nil, use_else_prefix: false, &block)
            full_expr =
              if condition_str
                pre_expr = use_else_prefix ? 'else if' : 'if'
                "#{pre_expr} (#{condition_str})"
              else
                unless use_else_prefix
                  fail 'Incorrect arguments was passed to combine code condition'
                end
                'else'
              end

            code_line(full_expr) + code_scope(&block)
          end

          # Gets the scope of code
          # @yield should return the body of scope
          # @return [String] the scoped code
          def code_scope(&block)
            code_lines('{', block.call, '}')
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

            code_lines("#{method_name}(#{args_wo_lambda_body} {", block.call, '});')
          end

          # Provides cpp code block with for loop statement
          # @param [String] iterator_type the type of iterator variable
          # @param [String] var_name the name of iterator variable
          # @param [Integer] max_value the limit value of for loop iteration
          # @yield [String] passes the name of iterator variable to passed block, this
          #   block should return a string with cpp code which will a body of loop
          #   statement
          # @return [String] the full code block with for loop statement
          def code_for_loop(iterator_type, var_name, max_value, &block)
            iterator = Object.new # any unique object which was not created previously
            namer.assign_next(var_name, iterator)
            i = name_of(iterator)

            code_line("for (#{iterator_type} #{i} = 0; #{i} < #{max_value}; ++#{i})") +
              code_scope { block[i] }
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

            var_name = name_of(vars)
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
            names_for(items).zip(items).map(&block).join(" #{operator} ")
          end
        end

      end
    end
  end
end
