module VersatileDiamond
  module Lattices

    # Provides useful methods for accessing to relation instances
    # TODO: inject into Concepts::Support::Handbook
    module BasicRelations
    private

      # Basics relation options
      [100, 110].each do |face|
        [:front, :cross].each do |dir|
          options = { face: face, dir: dir }
          define_method("#{dir}_#{face}") do
            options
          end

          define_method("bond_#{dir}_#{face}") do
            Concepts::Bond[options]
          end

          define_method("position_#{dir}_#{face}") do
            Concepts::Position[options]
          end
        end
      end

      # Undirected bond
      def undirected_bond
        Concepts::Bond[face: nil, dir: nil]
      end
    end

  end
end
