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
          # @param [Organizers::ProxyParentSpec] proxy_spec the original proxy parent
          #   spec by which was created current instance
          def initialize(original_specie, proxy_spec)
            super(original_specie)
            @proxy_spec = proxy_spec
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
        end

      end
    end
  end
end
