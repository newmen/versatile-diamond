module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code
      module Algorithm

        # Accumulates the names of variables for generation algorithms in cpp code
        class NameRemember
          # Initializes internal store for all using names
          def initialize
            @names = {}
            @next_names = []
          end

          # Assign unique names for each variables with duplicate error checking
          # @param [String] single_name the singular name of one variable
          # @param [Array | Object] vars the list of remembing variables or single
          #   variable
          def reassign(single_name, vars)
            store_variables(:replace, single_name, vars)
          end

          # Assign unique names for each variables with duplicate error checking
          # @param [String] single_name the singular name of one variable
          # @param [Array | Object] vars the list of remembing variables or single
          #   variable
          def assign(single_name, vars)
            store_variables(:check_and_store, single_name, vars)
          end

          # Assign next unique name for variable
          # @param [String] name without additional index what will using for make a new
          #   next name of variable
          # @param [Object] var the variable for which name will assigned
          def assign_next(name, var)
            last_name = @next_names.find { |n| n =~ /^#{name}\d+$/ }
            max_index = (last_name && last_name.scan(/\d+$/).first.to_i) || 0
            next_name = "#{name}#{max_index.next}"
            @next_names.unshift(next_name)
            assign(next_name, var)
          end

          # Gets a name of variable
          # @param [Array | Object] vars the variables or single variable for which
          #   name will be gotten
          # @return [String] the name of passed variable or nil
          def name_of(vars)
            if single?(vars)
              names[single_value(vars)]
            else
              check_proc = proc { |var| names[var] }
              if vars.all?(&check_proc)
                array_name_for(vars)
              elsif vars.any?(&check_proc)
                raise 'Not for all variables in passed set the name is presented'
              else
                nil
              end
            end
          end

          # Removes records about passed variables
          # @param [Array | Object] vars the variables or single variable which will be
          #   removed from internal cache
          def erase(vars)
            as_arr(vars).each { |var| names.delete(var) }
          end

        private

          attr_reader :names

          # Gets a hash where keys are names and values are variables
          # @return [Hash] the inverted names hash
          def variables
            names.invert
          end

          # Wraps passed variable to array if it not an array
          # @param [Array | Object] vars the cheking and may be wrapping variable
          # @return [Array] the original array or wrapped to array variable
          def as_arr(vars)
            vars.is_a?(Array) ? vars : [vars]
          end

          # Checks that passed variable is single
          # @param [Array | Object] vars the checkable variable
          # @return [Boolean] is single or not
          def single?(vars)
            !vars.is_a?(Array) || vars.size == 1
          end

          # Gets the value of single variable
          # @param [Array | Object] vars the single variable for which value will be
          #   gotten
          # @return [Object] the value of single variable
          def single_value(vars)
            vars.is_a?(Array) ? vars.first : vars
          end

          # Gets an array name for variables
          # @param [Array] vars the variables for which array name will be gotten
          # @return [String] the name of array that respond to passed variables
          def array_name_for(vars)
            stored_names = vars.map { |var| names[var] }
            array_name = stored_names.first.scan(/^\w+/).first

            # checking
            stored_names.each do |name|
              unless name.match(/^#{array_name}\[\d+\]$/)
                raise 'Not all vars belongs to array'
              end
            end

            array_name
          end

          # Assign unique names for each variables
          # @param [Symbol] method_name the method of name which will used for assign
          #   name for each variable
          # @param [String] single_name the singular name of one variable
          # @param [Array | Object] vars the list of remembing variables or single
          #   variable
          def store_variables(method_name, single_name, vars)
            if single?(vars)
              send(method_name, single_name, single_value(vars))
            else
              plur_name = single_name.pluralize
              vars.each_with_index do |var, i|
                send(method_name, "#{plur_name}[#{i}]", var)
              end
            end
          end

          # Stores a variable with some name with duplicate error checking
          # @param [String] name the name of storing variable
          # @param [Object] var the storing variable
          def check_and_store(name, var)
            raise "Variable \"#{name}\" already exists" if names[var]
            raise "Name \"#{name}\" already used" if variables[name]
            names[var] = name
          end

          # Replases a variable with some name without error checking
          # @param [String] name the name of storing variable
          # @param [Object] var the storing variable
          def replace(name, var)
            replasing_var = variables[name]
            names.delete(replasing_var)
            names[var] = name
          end
        end

      end
    end
  end
end
