module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code
      module Algorithm::Units

        # Accumulates the names of variables for generation algorithms in cpp code
        class NameRemember
          # Initializes internal store for all using names
          def initialize
            init!
            @checkpoints = []
          end

          # Saves current state to stack for future rollback to it if need
          def checkpoint!
            @checkpoints << {
              names: @names.dup,
              next_names: @next_names.dup,
              used_names: @used_names.dup
            }
          end

          # Restores previously saved state
          # @option [Boolean] :forget is the flag which if is set then last checkpoint
          #   will be forgotten
          def rollback!(forget: false)
            state = forget ? @checkpoints.pop : @checkpoints.last
            if state
              @names = state[:names].dup
              @next_names = state[:next_names].dup
              @used_names = state[:used_names].dup
            else
              init!
            end
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
          # @option [Boolean] :plur_if_need is a flag which if set then passed name
          #   should be pluralized
          def assign(single_name, vars, plur_if_need: true)
            args = [:check_and_store, single_name, vars]
            store_variables(*args, plur_if_need: plur_if_need)
          end

          # Assign next unique name for variable
          # @param [String] single_name without additional index what will using for
          #   make a new next name of variable
          # @param [Object] var the variable for which name will assigned
          def assign_next(single_name, var)
            correct_name = single?(var) ? single_name : single_name.pluralize
            last_name = @next_names.find { |n| n =~ /^#{correct_name}\d+$/ }
            max_index = (last_name && last_name.scan(/\d+$/).first.to_i) || 0
            next_name = "#{correct_name}#{max_index.next}"
            @next_names.unshift(next_name)
            assign(next_name, var, plur_if_need: false)
          end

          # Gets a name of variable
          # @param [Array | Object] vars the variables or single variable for which
          #   name will be gotten
          # @return [String] the name of passed variable or nil
          def name_of(vars)
            if single?(vars)
              names[single_value(vars)]
            else
              check_lambda = -> var { names[var] }
              if vars.all?(&check_lambda)
                name = array_name_for(vars)
                raise 'Not all vars belongs to array' unless name
                name
              elsif vars.any?(&check_lambda)
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

          # Checks that passed vars have same array variable name
          # @param [Array] vars the list of variables which will be checked
          # @return [Boolean] are vars have same array variable name or not
          def full_array?(vars)
            vars.all?(&method(:name_of)) && !!array_name_for(vars)
          end

        private

          attr_reader :names

          # Assigns default values to internal containers
          def init!
            @names = {}
            @next_names = []
            @used_names = Set.new
          end

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

            match_lambda = -> name { name.match(/^#{array_name}\[\d+\]$/) }
            is_array = stored_names.all?(&match_lambda) &&
              @used_names.select(&match_lambda).size == vars.size

            is_array ? array_name : nil
          end

          # Assign unique names for each variables
          # @param [Symbol] method_name the method of name which will used for assign
          #   name for each variable
          # @param [String] single_name the singular name of one variable
          # @param [Array | Object] vars the list of remembing variables or single
          #   variable
          # @option [Boolean] :plur_if_need see at #assign same option
          def store_variables(method_name, single_name, vars, plur_if_need: true)
            if single?(vars)
              send(method_name, single_name, single_value(vars))
            else
              plur_name = plur_if_need ? single_name.pluralize : single_name
              vars.each_with_index do |var, i|
                send(method_name, "#{plur_name}[#{i}]", var)
              end
            end
          end

          # Stores a variable with some name with duplicate error checking
          # @param [String] name the name of storing variable
          # @param [Object] var the storing variable
          def check_and_store(name, var)
            raise %(Variable "#{name}" already has name "#{names[var]}") if names[var]
            raise %(Name "#{name}" already used) if variables[name]
            remember(name, var)
          end

          # Replases a variable with some name without error checking
          # @param [String] name the name of storing variable
          # @param [Object] var the storing variable
          def replace(name, var)
            replasing_var = variables[name]
            names.delete(replasing_var)
            remember(name, var)
          end

          # Remembers the name of variable
          # @param [String] name the name of storing variable
          # @param [Object] var the storing variable
          def remember(name, var)
            @used_names << name
            names[var] = name
          end
        end

      end
    end
  end
end
