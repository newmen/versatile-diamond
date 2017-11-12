module VersatileDiamond
  module Lattices

    module BondLengths
      class << self
        def rad(angle)
          angle * Math::PI / 180
        end
      end

      SP_ANGLE = rad(180)
      SP2_ANGLE = rad(120)
      SP3_ANGLE = rad(109.28)

      FREE_BOND_LENGTHS = {
        [:C, :C].freeze => 1.7e-10
      }.freeze

    end

  end
end
