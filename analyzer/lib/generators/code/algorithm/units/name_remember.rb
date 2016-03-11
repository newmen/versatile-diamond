module VersatileDiamond
  using Patches::RichArray
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
              used_names: @used_names.dup,
              prev_names: Marshal.load(Marshal.dump(@prev_names))
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
              @prev_names = Marshal.load(Marshal.dump(state[:prev_names]))
            else
              init!
            end
          end

          # Assign unique names for each variables with duplicate error checking
          # @param [Array | Object] vars the list of remembing variables or single
          #   variable
          # @param [String] single_name the singular name of one variable
          # @return [String] the assigned name
          def reassign!(vars, single_name)
            store_variables(:replace, vars, single_name)
            name_of(vars)
          end

          # Assign unique names for each variables with duplicate error checking
          # @param [Array | Object] vars the list of remembing variables or single
          #   variable
          # @param [String] single_name the singular name of one variable
          # @option [Boolean] :pluralize is a flag which if set then passed name
          #   should be pluralized
          # @return [String] the assigned name
          def assign!(vars, single_name, pluralize: true)
            store_variables(:check_and_store, vars, single_name, pluralize: pluralize)
            name_of(vars)
          end

          # Assign next unique name for variable
          #   make a new next name of variable
          # @param [Object] var the variable for which name will assigned
          # @param [String] single_name without additional index what will using for
          def assign_next!(var, single_name)
            correct_name = single?(var) ? single_name : single_name.pluralize
            last_name = @next_names.find { |n| n =~ /^#{correct_name}\d+$/ }
            max_index = (last_name && last_name.scan(/\d+$/).first.to_i) || 0
            next_name = "#{correct_name}#{max_index.next}"
            @next_names.unshift(next_name)
            assign!(var, next_name, pluralize: false)
          end

          # Gets a previous names of variable
          # @param [Object] var the variable for which previous names will be gotten
          # @return [Array] the list of previous names of passed variable or nil
          # @deprecated
          def prev_names_of(var)
            if single?(var)
              @prev_names[var]
            else
              raise ArgumentError, 'Previos names of array cannot be resolved'
            end
          end

          # Gets a name of variable
          # @param [Array | Object] vars the variables or single variable for which
          #   name will be gotten
          # @return [String] the name of passed variable or nil
          def name_of(vars)
            if single?(vars)
              names[single_value(vars)]
            else
              if vars.all?(&names.method(:[]))
                name = array_name_for(vars)
                name ? name : raise(ArgumentError, 'Not all vars belongs to array')
              elsif vars.any?(&names.method(:[]))
                msg = 'Not for all variables in passed set the name is presented'
                raise ArgumentError, msg
              else
                nil
              end
            end
          end

          # @return [Array] the list of defined variables
          def defined_vars
            names.keys
          end

          # Removes records about passed variables
          # @param [Array | Object] vars the variables or single variable which will be
          #   removed from internal cache
          # @return [Array | String] the erased names
          def erase(vars)
            result = as_arr(vars).map(&method(:delete))
            single?(vars) ? result.first : result
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
            @prev_names = {}
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
            !vars.is_a?(Array) || vars.one?
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
            using_names = match_arrays(vars.map(&names.method(:[])))
            return nil unless using_names.size == vars.size && using_names.all_equal?

            any_name = using_names.first
            all_names = match_arrays(names.values).select { |n| n == any_name }
            is_array = all_names.size == using_names.size && all_names.all_equal?
            is_array ? all_names.first : nil
          end

          # Collects array names in passed variable names list
          # @param [Array] checking_names which will be checked
          # @return [Array] the list of arrays variables
          def match_arrays(checking_names)
            checking_names.each_with_object([]) do |name, acc|
              m = name.match(/^(?<array_name>\w+)\[\d+\]$/)
              acc << m[:array_name] if m
            end
          end

          # Assign unique names for each variables
          # @param [Symbol] method_name the method of name which will used for assign!
          #   name for each variable
          # @param [Array | Object] vars the list of remembing variables or single
          #   variable
          # @param [String] single_name the singular name of one variable
          # @option [Boolean] :pluralize see at #assign! same option
          def store_variables(method_name, vars, single_name, pluralize: true)
            if single?(vars)
              send(method_name, single_value(vars), single_name)
            else
              plur_name = pluralize ? single_name.pluralize : single_name
              vars.each_with_index do |var, i|
                send(method_name, var, "#{plur_name}[#{i}]")
              end
            end
          end

          # Stores a variable with some name with duplicate error checking
          # @param [Object] var the storing variable
          # @param [String] name the name of storing variable
          def check_and_store(var, name)
            raise %(Variable "#{name}" already has name "#{names[var]}") if names[var]
            raise %(Name "#{name}" already used) if variables[name]
            remember(var, name)
          end

          # Replases a variable with some name without error checking
          # @param [Object] var the storing variable
          # @param [String] name the name of storing variable
          def replace(var, name)
            delete(var)
            delete(variables[name])
            remember(var, name)
          end

          # Deletes variable name from avail names list
          # @param [Object] var for which the name will be forgotten
          def delete(var)
            store_prev_name(var) if names[var]
            names.delete(var)
          end

          # Stores previous name of variable
          # @param [Object] var which name will be remembered as previous
          def store_prev_name(var)
            @prev_names[var] ||= []
            @prev_names[var] << names[var]
          end

          # Remembers the name of variable
          # @param [Object] var the storing variable
          # @param [String] name the name of storing variable
          def remember(var, name)
            freezed_name = name.freeze
            @used_names << freezed_name
            names[var] = freezed_name
          end
        end

      end
    end
  end
end
