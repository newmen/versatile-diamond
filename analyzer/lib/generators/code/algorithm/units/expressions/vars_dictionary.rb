module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Collects all defined variables as references from variable instances
        class VarsDictionary < BaseDictionary
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

        private

          ATOM_TYPE = AtomType[].ptr.freeze
          DEFAULT_SPECIE_NAME = Code::Specie::INTER_SPECIE_NAME
          ITERATOR_TYPE = Core::ScalarType['uint'].freeze
          ITERATOR_INIT_VALUE = Core::Constant[0].freeze

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
