module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Collects all defined variables as references from variable instances
        class VarsDictionary
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

          # @param [Object] atom_s
          # @option [String] :name
          # @option [Core::Expression] :value
          # @param [Hash] nopts
          # @return [Core::Variable]
          def make_atom_s(atom_s, name: nil, value: nil, **nopts)
            make_var_s(:atom, atom_s, ATOM_TYPE, name, value, **nopts)
          end

          # @param [Object] specie_s
          # @option [Core::ObjectType] :type
          # @option [String] :name
          # @option [Core::Expression] :value
          # @param [Hash] nopts
          # @return [Core::Variable]
          def make_specie_s(specie_s, type: nil, name: nil, value: nil, **nopts)
            make_var_s(:specie, specie_s, type, name, value, **nopts)
          end

          # @param [Sybmol] x
          # @param [Hash] nopts
          # @return [Core::Variable]
          def make_iterator(x, **nopts)
            nopts[:next_name] ||= false
            name = fix_name(x.to_s, **nopts)
            store!(Core::Variable[x, ITERATOR_TYPE, name, ITERATOR_INIT_VALUE])
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
            @vars.flat_map(&:last).reject(&:item?)
          end

        private

          ATOM_TYPE = AtomType[].ptr.freeze
          DEFAULT_SPECIE_NAME = Code::Specie::INTER_SPECIE_NAME
          ITERATOR_TYPE = ScalarType['uint'].freeze
          ITERATOR_INIT_VALUE = Constant[0].freeze

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

          # @param [Object] instance
          # @param [Array] args
          # @param [Hash] nopts
          # @return [Core::Variable]
          def make_var_s(prefix, instance, type, name, value, **nopts)
            if array?(instance)
              send(:"#{prefix}s_array", instance, type, name, value, **nopts)
            else
              method_name = :"#{prefix}_variable"
              fixed_instance = fix_instance(instance)
              fixed_value = fix_instance(value)
              send(method_name, fixed_instance, type, name, fixed_value, **nopts)
            end
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

          # @param [Array] atoms
          # @return [String]
          def select_atom_name(*atoms)
            if atoms.any?(&:lattice)
              Code::Specie::INTER_ATOM_NAME
            else
              Code::Specie::AMORPH_ATOM_NAME
            end
          end

          # @param [Concepts::Atom | Concepts::SpecificAtom | Concepts::AtomReference]
          #   atom variable of which will be maked
          # @param [Core::ScalarType] type
          # @param [String] name
          # @param [Object] value
          # @param [Hash] nopts
          # @return [AtomVariable]
          def atom_variable(atom, type, name = nil, value = nil, **nopts)
            name = fix_name(name || select_atom_name(atom), **nopts)
            store!(AtomVariable[atom, type, name, value])
          end

          # @param [Array] atoms
          # @param [Core::ScalarType] type
          # @param [String] name
          # @param [Array] values
          # @return [Core::Variable]
          def atoms_array(atoms, type, name = nil, values = nil, **nopts)
            name = fix_name(name || select_atom_name(*atoms), plur: true, **nopts)
            items = array_items(:atom_variable, atoms, type, name, values)
            store!(AtomsArray[items, type, name, values])
          end

          # @param [Instances::SpecieInstance] specie variable of which will be maked
          # @param [Core::ObjectType] type
          # @param [String] name
          # @param [Object] value
          # @param [Hash] nopts
          # @return [SpecieVariable]
          def specie_variable(specie, type = nil, name = nil, value = nil, **nopts)
            type ||= specie_type(specie)
            name = fix_name(name || specie.var_name, **nopts)
            store!(SpecieVariable[specie, type.ptr, name, value])
          end

          # @param [Array] species
          # @param [Core::ObjectType] type
          # @param [String] name
          # @param [Array] values
          # @return [Core::Variable]
          def species_array(species, type = nil, name = nil, values = nil, **nopts)
            if type || species.map(&:original).uniq.one?
              ptr_type = (type || specie_type(species.first)).ptr
              name = fix_name(name || DEFAULT_SPECIE_NAME, plur: true, **nopts)
              items = array_items(:specie_variable, species, ptr_type, name, values)
              store!(SpeciesArray[items, ptr_type, name, values])
            else
              raise ArgumentError, 'Ambiguous array variable type for species'
            end
          end

          # @param [Instances::SpecieInstance] specie variable of which will be maked
          # @return [Core::ObjectType]
          def specie_type(specie)
            Core::ObjectType[specie.original.class_name]
          end

          # @param [Symbol] method_name
          # @param [Array] instances
          # @param [Core::ScalarType] type
          # @param [String] plur_name
          # @param [Array] values
          # @return [Array]
          def array_items(method_name, instances, type, plur_name, values)
            items_names = instances_names(instances, plur_name)
            zip_vars(method_name, instances, type, items_names, values)
          end

          # @param [Symbol] method_name
          # @param [Array] instances
          # @param [Core::ScalarType] type
          # @param [Array] names
          # @param [Array] values
          # @return [Array]
          def zip_vars(method_name, instances, type, names, values)
            instances.zip(names, values || [nil].cycle).map do |inst, name, val|
              send(method_name, inst, type, name, val, next_name: false)
            end
          end

          # @param [Array] instances
          # @param [String] plur_name
          # @return [Array]
          def instances_names(instances, plur_name)
            instances.map.with_index { |_, i| "#{plur_name}[#{i}]" }
          end
        end

      end
    end
  end
end
