module VersatileDiamond
  module Generators
    module Formula

      class Walker
        def initialize(start_atom)
          @mx = CrystalMatrix.new(start_atom)
        end

        def over(atom, rels)
          from_node = mx.node_with(atom)
          just_crystal(rels).all? do |nbr, rel|
            mx.steps_by(rel, from_node) do |to_node|
              if !to_node.atom
                to_node.atom = nbr

              elsif to_node.atom != nbr
              else
              end
            end
          end
        end

      private

        attr_reader :mx

        def just_crystal(rels)
          rels.select { |_, rel| rel.relation? && rel.belongs_to_crystal? }
        end
      end

    end
  end
end
