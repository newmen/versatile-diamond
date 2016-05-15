module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Replaces internal unique specie
        class SideNode < Tools::TransparentProxy
          def initialize(*)
            super
            @_replaced_uniq_specie = nil
          end

          # @return [Instances::OtherSideSpecie]
          def uniq_specie
            @_replaced_uniq_specie ||=
              Algorithm::Instances::OtherSideSpecie.new(original.uniq_specie)
          end
        end

      end
    end
  end
end
