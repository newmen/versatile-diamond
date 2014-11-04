module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Wraps each real specie code generator for difference naming when find
        # algorithm builds
        class UniqueSpecie < Tools::TransparentProxy
          def none?
            false
          end

          def scope?
            false
          end
        end

      end
    end
  end
end
