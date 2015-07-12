module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Also contains the different dependent spec
        class ReactantNode < Node
          # Checks that target atom is anchor in original specie
          # @return [Boolean] is anchor or not
          def anchor?
            dept_spec.anchors.include?(atom)
          end

          # Gets the dependent spec from unique specie
          # @return [Organizers::DependentWrappedSpec] the dependent spec
          def dept_spec
            uniq_specie.proxy_spec
          end

          # Makes reaction links graph vertex from passed node
          # @return [Array] the reaction links graph vertex
          def spec_atom
            [dept_spec.spec, atom]
          end

          def inspect
            ":#{super}:"
          end
        end

      end
    end
  end
end
