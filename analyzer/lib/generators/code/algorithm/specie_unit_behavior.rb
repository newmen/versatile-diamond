module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for algorithm builder units
        module SpecieUnitBehavior
          extend Forwardable

          # By default assigns internal anchor atoms to some names for using its in
          # find algorithm
          def first_assign!
            assign_anchor_atoms_name!
          end

          # Gets the code which checks that containing in unit instance is presented
          # or not
          #
          # @param [String] else_prefix which will be used if current instance has
          #   a several anchor atoms
          # @yield should return cpp code which will be used if unit instance is
          #   presented
          # @return [String] the cpp code string
          def check_existence(else_prefix = '', &block)
            define_anchor_atoms_lines +
              code_condition(check_role_condition(atoms), else_prefix) do
                code_condition(check_specie_condition(atoms), &block)
              end
          end

          # Does nothing by default
          # @yield should return cpp code
          # @return [String] the cpp code string
          def check_species(&block)
            block.call
          end

        private

          def_delegator :spec, :relation_between

          # Assigns the name of anchor atoms variable
          def assign_anchor_atoms_name!
            namer.assign(Specie::ANCHOR_ATOM_NAME, atoms)
          end

          # By default doesn't define anchor atoms
          # @return [String] the empty string
          def define_anchor_atoms_lines
            ''
          end

          # Gets a cpp code string that contain call a method for check existing
          # current specie in atom
          #
          # @param [Array] atoms which role will be checked in code
          # @return [String] the string with cpp condition
          def check_specie_condition(atoms)
            method_name = original_specie.find_endpoint? ? 'hasRole' : 'checkAndFind'
            combine_condition(atoms, '||') do |var, atom|
              "!#{var}->#{method_name}(#{original_specie.enum_name}, #{role(atom)})"
            end
          end
        end

      end
    end
  end
end
