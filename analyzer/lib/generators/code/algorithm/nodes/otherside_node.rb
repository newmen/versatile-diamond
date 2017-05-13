module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Replaces internal unique specie
        class OthersideNode < LateralNode

          delegate :sub_properties, :coincide?

          # @param [LateralChunks] _
          # @param [ReactantNode] _
          def initialize(*)
            super
            @_otherside_specie = nil
          end

          # @return [Instances::OtherSideSpecie]
          def uniq_specie
            @_otherside_specie ||=
              Algorithm::Instances::OtherSideSpecie.new(original.uniq_specie)
          end

          # @return [Boolean]
          # @override
          def side?
            true
          end
        end

      end
    end
  end
end
