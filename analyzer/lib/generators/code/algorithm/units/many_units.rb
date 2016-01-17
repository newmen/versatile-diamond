module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code from many node
        # @abstract
        class ManyUnits < BaseCheckerUnit
          class << self
            # Defines the methods which collects and caches the data by method name
            # from internal units
            #
            # @param [Array] method_names by each of which the data will be aggregated
            def aggregate(*method_names)
              method_names.each do |method_name|
                cache_var = :"@_#{method_name}"
                # Gets the current #{method_name}
                # @return [Array] the array of #{method_name} from internal units
                define_method(method_name) do
                  instance_variable_get(cache_var) ||
                    instance_variable_set(cache_var,
                      instance_variable_get(:@units).flat_map(&method_name))
                end
              end
            end
          end

          aggregate :units, :species, :atoms, :all_using_relations

          # Initializes the many checking units of code builder algorithm
          # @param [Array] default_args which will be passed to super class
          # @param [Array] units which should be checked at one time
          def initialize(*default_args, units)
            super(*default_args)
            @units = units
            @atoms_to_units = map_atoms_to_units(units)

            @_units, @_species, @_atoms, @_all_using_relations = nil
          end

          # Selects internal units which uses passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the units will be found
          # @return [Array] the inner units list
          def inner_units_with(atom)
            @atoms_to_units[atom]
          end

          # Detects the role of passed atom
          # @return [Integer] the role of atom
          def detect_role(atom)
            inner_unit_by(atom).detect_role(atom)
          end

          def inspect
            "(#{@units.map(&:inspect).join('+')})"
          end

        private

          # Maps the atoms from internal units to it units
          # @param [Array] inner_units which will be mapped to atoms
          # @return [Hash] the pseudo multimap structure
          def map_atoms_to_units(inner_units)
            inner_units.each_with_object({}) do |unit, result|
              unit.atoms.each do |atom|
                result[atom] ||= []
                result[atom] += [unit]
              end
            end
          end

          # Gets internal unit which uses passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the unit will be found
          # @return [BaseCheckerUnit] the inner unit or nil
          def inner_unit_by(atom)
            units_with_atom = inner_units_with(atom).to_a
            if similar_units?(units_with_atom)
              return units_with_atom.sort_by { |un| un.species.size }.first
            else
              raise 'Too many different internal units are used the passed atom'
            end
          end

          # Checks that all passed units are equal
          # @param [Symbol] method_name by which the comparation will be done
          # @param [Array] checking_units which will be checked
          # @return [Boolean] are all passed units similar or not
          def similar?(method_name, checking_units)
            comparing_units = checking_units.dup
            first_unit = comparing_units.shift
            comparing_units.all? { |un| first_unit.send(method_name, un) }
          end

          # Checks that states of all passed units are equal
          # @param [Array] checking_units which will be checked
          # @return [Boolean] are all states passed units similar or not
          def similar_units?(checking_units)
            similar?(:same_state?, checking_units)
          end

          # Compares using relations of passed units
          # @param [Array] checking_units which relations will be checked
          # @return [Boolean] are all relations of passed units similar or not
          def similar_relations?(checking_units)
            similar?(:same_relations?, checking_units)
          end

          # Checks that all inner units are equal
          # @return [Boolean] are all inner units similar or not
          def equal_inner_units?
            similar_units?(@units) && similar_relations?(@units)
          end

          # Checks that symmetries of internal specie should be also checked
          # @return [Boolean] are symmetries should be checked or not
          def symmetric_unit?
            contexts = @units.map(&:symmetric_unit?)
            contexts.any? && (mono? || !(contexts.all? && equal_inner_units?))
          end
        end

      end
    end
  end
end
