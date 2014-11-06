module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Wraps each real specie code generator for difference naming when find
        # algorithm builds
        class UniqueSpecie < Tools::TransparentProxy
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
