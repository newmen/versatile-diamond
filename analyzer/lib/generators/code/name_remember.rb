module VersatileDiamond
  module Generators
    module Code

      # Accumulates the names of variables for generation algorithms in cpp code
      class NameRemember
        # Initializes internal store for all using names
        def initialize
          @names = {}
        end

        # Assign unique names for each variables with duplicate error checking
        # @param [String] single_name the singular name of one variable
        # @param [Array] vars the list of remembing variables
        def assign(single_name, vars)
          store_variables(:check_and_store, single_name, vars)
        end

        # Assign next unique name for variable
        # @param [String] name without additional index what will using for make a new
        #   next name of variable
        # @param [Object] var the variable for which name will assigned
        def assign_next(name, var)
          same_names = names.select { |_, n| n =~ /^#{name}\d+$/ }.map(&:last)
          last_name = same_names.sort.last
          max_index = (last_name && last_name.scan(/\d+$/).first.to_i) || 0
          assign("#{name}#{max_index + 1}", [var])
        end

        # Assign unique names for each variables with duplicate error checking
        # @param [String] single_name the singular name of one variable
        # @param [Array] vars the list of remembing variables
        def reassign(single_name, vars)
          store_variables(:replace, single_name, vars)
        end

        # Gets a name of variable
        # @param [Object] var the variable for which name will be gotten
        # @return [String] the name of passed variable
        def get(var)
          raise 'Variable is undefined' unless names[var]
          names[var]
        end

        # Gets an array name for variables
        # @param [Array] vars the variables for which array name will be gotten
        # @return [String] the name of array that respond to passed variables
        def array_name_for(vars)
          stored_names = vars.map(&method(:get))
          array_name = stored_names.first.scan(/^\w+/).first

          # checking
          stored_names.each do |name|
            unless name.match(/^#{array_name}\[\d+\]$/)
              raise 'Not all vars belongs to array'
            end
          end

          array_name
        end

      private

        attr_reader :names

        # Gets a hash where keys are names and values are variables
        # @return [Hash] the inverted names hash
        def variables
          names.invert
        end

        # Assign unique names for each variables
        # @param [Symbol] method_name the method of name which will used for assign
        #   name for each variable
        # @param [String] single_name the singular name of one variable
        # @param [Array] vars the list of remembing variables
        def store_variables(method_name, single_name, vars)
          raise 'Variables is not presented' if vars.empty?

          if vars.size == 1
            send(method_name, single_name, vars.first)
          else
            vars.each_with_index do |var, i|
              send(method_name, "#{single_name}s[#{i}]", var)
            end
          end
        end

        # Stores a variable with some name with duplicate error checking
        # @param [String] name the name of storing variable
        # @param [Object] var the storing variable
        def check_and_store(name, var)
          raise "Variable #{name} already exists" if names[var]
          raise "Name #{name} already used" if variables[name]
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
