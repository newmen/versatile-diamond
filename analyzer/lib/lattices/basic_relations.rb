module VersatileDiamond
  module Lattices

    # Provides useful methods for accessing to relation instances
    # TODO: inject into Concepts::Support::Handbook
    module BasicRelations

      module Amorph
        # Undirected mono bond
        def undirected_bond
          Concepts::Bond.amorph
        end

        # Undirected double bond
        def double_bond
          Concepts::MultiBond[2]
        end

        # Undirected triple bond
        def triple_bond
          Concepts::MultiBond[3]
        end
      end

      module Crystal
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
      end

    private

      include Amorph
      include Crystal

    end

  end
end
