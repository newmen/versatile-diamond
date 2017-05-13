module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Collects all defined variables as references from variable instances
        # @abstract
        class BaseDictionary
          def initialize
            reset!
            @checkpoints = []
          end

          # Saves current state to stack for future rollback to it if need
          def checkpoint!
            @checkpoints << current_state
          end

          # Restores previously saved state
          # @option [Boolean] :forget is the flag which if is set then last checkpoint
          #   will be forgotten
          def rollback!(forget: false)
            state = forget ? @checkpoints.pop : @checkpoints.last
            if state
              forget ? force_restore!(state) : restore!(state)
            else
              reset!
            end
          end

          # @param [Object] instance
          # @return [Core::Variable] or nil
          def var_of(instance)
            used_vars = @vars[key_of(instance)]
            used_vars && used_vars.last
          end

          # @param [Object] instance
          # @return [Core::Variable] or nil
          def prev_var_of(instance)
            (@vars[key_of(instance)] || [])[0..-2].last
          end

          # @return [Array]
          def defined_vars
            all_defined_vars.reject(&:item?)
          end

        private

          def reset!
            @vars = {}
            @next_names = []
            @used_names = Set.new
          end

          # @return [Hash]
          def current_state
            {
              vars: deep_hash_dup(@vars),
              next_names: @next_names.dup,
              used_names: @used_names.dup
            }
          end

          # @param [Hash] state
          def restore!(state)
            force_restore!(state)
          end

          # @param [Hash] state
          def force_restore!(state)
            @vars = deep_hash_dup(state[:vars])
            @next_names = state[:next_names].dup
            @used_names = state[:used_names].dup
          end

          # @param [Hash] vars
          # @return [Hash]
          def deep_hash_dup(vars)
            vars.each_with_object({}) do |(k, vs), acc|
              acc[k] = vs.dup
            end
          end

          # @return [Array]
          def all_defined_vars
            @vars.flat_map(&:last)
          end

          # @param [Object] instance
          # @return [Boolean]
          def array?(instance)
            fix_instance(instance).is_a?(Array)
          end

          # @param [Core::Variable]
          # @return [Core::Variable]
          def store!(var)
            key = key_of(var.instance)
            @vars[key] ||= []
            @vars[key] << var
            var
          end

          # @param [Object] instance
          # @return [Object]
          def key_of(instance)
            fix_instance(instance) { |arr| arr.to_set.freeze }
          end

          # @param [Object] instance
          # @yield [Array]
          # @return [Object]
          def fix_instance(instance, &block)
            if instance.is_a?(Array)
              if instance.one?
                instance.first
              else
                block_given? ? block[instance] : instance
              end
            else
              instance
            end
          end

          # @param [String] name
          # @option [Boolean] :plur
          # @option [Boolean] :next_name
          # @return [String]
          def fix_name(name, plur: false, next_name: true)
            result = name
            result = result.pluralize if plur
            if next_name
              inc_name(result)
            elsif !@used_names.include?(result)
              @used_names.add(result)
              result
            else
              raise ArgumentError, "Name '#{result}' already used"
            end
          end

          # @param [String] name
          # @return [String]
          def inc_name(name)
            last_name = @next_names.find { |n| n =~ /^#{name}\d+$/ }
            max_index = (last_name && last_name.scan(/\d+$/).first.to_i) || 0
            next_name = "#{name}#{max_index.next}"
            @next_names.unshift(next_name)
            @used_names.add(next_name)
            next_name
          end
        end

      end
    end
  end
end
