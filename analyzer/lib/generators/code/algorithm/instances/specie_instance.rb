module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # The base role for algorithm instances
        module SpecieInstance
          include Modules::OrderProvider
          extend Forwardable

          def_delegator :spec, :anchors

          # Compares two specie instances that were initially high and then a small
          # @param [SpecieInstance] other comparable specie
          # @return [Integer] the comparing result
          def <=> (other)
            typed_order(other, self, :scope?) do
              typed_order(self, other, :none?) do
                comparing_core(other)
              end
            end
          end

          # Gets concept specie
          # @return [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          def concept
            spec.spec
          end

          %i(index role).each do |name|
            # Gets correct #{name} of atom in original atoms sequence
            # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
            #   atom the #{name} for which will be gotten
            # @return [Integer] the #{name} of atom
            define_method(name) do |atom|
              original.public_send(name, original_atom(atom))
            end
          end

          # Gets atom properties of passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which properties will be returned
          # @return [Organizers::AtomProperties] the properties of passed atom
          def properties_of(atom)
            generator.atom_properties(spec, reflection_of(atom))
          end

          # Checks that passed atom is anchor
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is anchor or not
          def anchor?(atom)
            anchors.include?(reflection_of(atom))
          end

        private

          # Compares two unique specie that were initially high and then a small
          # @param [SpecieInstance] other comparable specie
          # @return [Integer] the comparing result
          def comparing_core(other)
            other.spec <=> spec
          end
        end

      end
    end
  end
end
