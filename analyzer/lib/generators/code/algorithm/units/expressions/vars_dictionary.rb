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
          # @param [Hash] opts
          # @return [Core::Variable]
          def make_atom_s(atom_s, **opts)
            make_var_s(:atom, atom_s, type: ATOM_TYPE, **opts)
          end

          # @param [Object] specie_s
          # @param [Hash] opts
          # @return [Core::Variable]
          def make_specie_s(specie_s, **opts)
            make_var_s(:specie, specie_s, **opts)
          end

          # @param [Sybmol] x
          # @param [Hash] opts
          # @return [Core::Variable]
          def make_iterator(x, **opts)
            type = ITERATOR_TYPE
            default_value = ITERATOR_INIT_VALUE
            store!(Core::Variable[x, type, x.to_s, value: default_value, **opts])
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

          ATOM_TYPE = AtomType[].ptr.freeze
          DEFAULT_SPECIE_NAME = Code::Specie::INTER_SPECIE_NAME
          ITERATOR_TYPE = Core::ScalarType['uint'].freeze
          ITERATOR_INIT_VALUE = Core::Constant[0].freeze

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
          # @param [Hash] opts
          # @return [Core::Variable]
          def make_var_s(prefix, instance, **opts)
            if array?(instance)
              send(:"#{prefix}s_array", instance, **opts)
            else
              opts[:value] &&= fix_instance(opts[:value])
              send(:"#{prefix}_variable", fix_instance(instance), **opts)
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
          # @option [AtomType] :type
          # @option [String] :name
          # @option [Core::Expression] :value
          # @option [Core::Expression] :index
          # @param [Hash] opts
          # @return [AtomVariable]
          def atom_variable(atom, type: nil, name: nil, value: nil, index: nil, **opts)
            name = fix_name(name || select_atom_name(atom), **opts) unless index
            store!(AtomVariable[atom, type, name, value: value, index: index])
          end

          # @param [Array] atoms
          # @option [AtomType] :type
          # @option [String] :name
          # @option [Array] :value
          # @option [Core::Expression] :index
          # @param [Hash] opts
          # @return [Core::Variable]
          def atoms_array(atoms, type: nil, name: nil, value: nil, index: nil, **opts)
            unless index
              name = fix_name(name || select_atom_name(*atoms), plur: true, **opts)
            end
            kwargs = { type: type, name: name }
            items = array_items(:atom_variable, atoms, value, **kwargs)
            store!(AtomsArray[items, type, name, value: value, index: index])
          end

          # @param [Instances::SpecieInstance] specie variable of which will be maked
          # @option [Core::ObjectType] :type
          # @option [String] :name
          # @option [Core::Expression] :value
          # @option [Core::Expression] :index
          # @param [Hash] opts
          # @return [SpecieVariable]
          def specie_variable(specie, type: nil, name: nil, value: nil, index: nil, **opts)
            type ||= specie_type(specie)
            name = fix_name(name || specie.var_name, **opts) unless index
            vix = { value: value, index: index }
            store!(SpecieVariable[specie, type.ptr, name, **vix])
          end

          # @param [Array] species
          # @option [Core::ObjectType] :type
          # @option [String] :name
          # @option [Array] :value
          # @option [Core::Expression] :index
          # @param [Hash] opts
          # @return [Core::Variable]
          def species_array(species, type: nil, name: nil, value: nil, index: nil, **opts)
            if type || species.map(&:original).uniq.one?
              unless index
                name = fix_name(name || DEFAULT_SPECIE_NAME, plur: true, **opts)
              end
              ptr_type = (type || specie_type(species.first)).ptr
              kwargs = { type: ptr_type, name: name }
              items = array_items(:specie_variable, species, value, **kwargs)
              store!(SpeciesArray[items, ptr_type, name, value: value, index: index])
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
          # @param [Array] values
          # @option [Hash] opts
          # @return [Array]
          def array_items(method_name, instances, values, **opts)
            vars_pairs = values || [nil].cycle
            instances.zip(vars_pairs).map.with_index do |(inst, val), i|
              opts.merge!({ value: val, index: Core::Constant[i], next_name: false })
              send(method_name, inst, **opts)
            end
          end
        end

      end
    end
  end
end
