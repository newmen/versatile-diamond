module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Wraps parent specie code generator proxy for difference naming when algorithm
        # builds, and parent atoms substitute instead passed atoms of original specie
        class UniqueParent < UniqueSpecie

          attr_reader :actual, :spec

          # Initializes unique parent specie
          # @param [EngineCode] generator the major code generator
          # @param [Organizers::ProxyParentSpec] proxy_parent spec by which the unique
          #   algorithm specie will be maked
          def initialize(generator, proxy_parent)
            super(generator, proxy_parent.spec)
            @spec = proxy_parent
            @actual = specie_class(proxy_parent.child.spec)
          end

          # Unique parent specie is not "no specie"
          # @return [Boolean] false
          def none?
            false
          end

          # Unique parent specie is not scope
          # @return [Boolean] false
          def scope?
            false
          end

        protected

          # Gets the atom which uses in child specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   twin of proxy specie which reflection will be returned
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the context atom
          def self_atom(twin)
            spec.atom_by(twin)
          end

        private

          define_itself_getter_by :actual_atom

          # Gets the atom which reflects passed atom of original specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom of original specie which reflection will be returned
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the reflected atom
          def original_atom(atom)
            spec.twin_of(atom)
          end

          # Compares two unique specie that were initially high and then a small
          # @param [UniqueParent] other comparable specie
          # @return [Integer] the comparing result
          # @override
          def comparing_core(other)
            other.spec.original <=> spec.original
          end
        end

      end
    end
  end
end
