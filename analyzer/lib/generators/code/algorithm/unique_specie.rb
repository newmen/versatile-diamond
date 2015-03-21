module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Wraps each real specie code generator for difference naming when find
        # algorithm builds
        class UniqueSpecie < Tools::TransparentProxy

          attr_reader :proxy_spec

          # Initializes unique specie
          # @param [Specie] original_specie the target code generator
          # @param [Organizers::DependentWrappedSpec | Organizers::ProxyParentSpec]
          #   proxy_spec the original proxy parent spec (for species case) or clone
          #   of depependent spec (for reactions case) by which was created current
          #   instance
          def initialize(original_specie, proxy_spec)
            super(original_specie)
            @proxy_spec = proxy_spec
          end

          %i(index role).each do |name|
            # Gets correct #{name} of atom in original atoms sequence
            # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
            #   atom the #{name} for which will be gotten
            # @return [Integer] the #{name} of atom
            define_method(name) do |atom|
              original.send(name, mirror[atom])
            end
          end

          # Compares two unique specie that were initially high and then a small
          # @param [UniqueSpecie] other comparable specie
          # @return [Integer] the comparing result
          def <=> (other)
            other.spec <=> spec
          end

          # Unique specie is not "no specie"
          # @return [Boolean] false
          def none?
            false
          end

          # Unique specie is not scope
          # @return [Boolean] false
          def scope?
            false
          end

        private

          # Gets the mirror from proxy spec to original dependent spec
          # @return [Hash] the mirror from proxy spec to original spec
          def mirror
            Mcs::SpeciesComparator.make_mirror(proxy_spec, original.spec)
          end
        end

      end
    end
  end
end
