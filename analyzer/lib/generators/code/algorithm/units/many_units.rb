module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code from many node
        # @abstract
        class ManyUnits < BaseCheckerUnit

          # Initializes the many checking units of code builder algorithm
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Array] units which should be checked at one time
          def initialize(generator, namer, units)
            super(generator, namer)
            @units = units

            @atoms_to_units = {}
            @units.each do |unit|
              unit.atoms.each do |atom|
                @atoms_to_units[atom] ||= []
                @atoms_to_units[atom] += [unit]
              end
            end

            @_species, @_atoms, @_specs_atoms, @_all_using_relations = nil
          end

          %i(species atoms specs_atoms all_using_relations).each do |method_name|
            cache_var = :"@_#{method_name}"
            # Gets the current #{method_name}
            # @return [Array] the array of #{method_name} from internal units
            define_method(method_name)
              instance_variable_get(cache_var) ||
                instance_variable_set(cache_var, @units.flat_map(&method_name))
            end
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

          # Gets internal unit which uses passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the unit will be found
          # @return [BaseCheckerUnit] the inner unit or nil
          def inner_unit_by(atom)
            units_with_atom = inner_units_with(atom).to_a
            if similar_units?(units_with_atom)
              return units_with_atom.sort_by { |un| un.species.size }.first
            else
              raise 'Too many different mono units uses passed atom'
            end
          end

          # Checks that all passed units are equal
          # @param [Symbol] method_name by which the comparation will be done
          # @param [Array] units which will be checked
          # @return [Boolean] are all passed units similar or not
          def similar?(method_name, units)
            checking_units = units.dup
            first_unit = checking_units.shift
            checking_units.all? { |un| first_unit.send(method_name, un) }
          end

          # Checks that states of all passed units are equal
          # @param [Array] units which will be checked
          # @return [Boolean] are all states passed units similar or not
          def similar_units?(units)
            similar?(:same_state?, units)
          end

          # Compares using relations of passed units
          # @param [Array] units which relations will be checked
          # @return [Boolean] are all relations of passed units similar or not
          def similar_relations?(units)
            similar?(:same_relations?, units)
          end

          # Checks that all inner units are equal
          # @return [Boolean] are all inner units similar or not
          def equal_inner_units?
            similar_units?(@units) && similar_relations?(@units)
          end

          # Checks that state of passed unit is same as current state
          # @param [MonoUnit] other comparing unit
          # @return [Boolean] are equal states of units or not
          def same_inner_state?(other)
            lists_are_identical?(specs_atoms, other.specs_atoms, &:same_sa?)
          end

          # Checks that symmetries of internal specie should be also checked
          # @return [Boolean] are symmetries should be checked or not
          def symmetric_context?
            results = @units.map(&:symmetric_context?)
            results.any? && !(results.all? && equal_inner_units?)
          end
        end

      end
    end
  end
end
