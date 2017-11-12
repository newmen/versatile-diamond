module VersatileDiamond
  module Generators
    module Formula

      # Knows how the specie located at the space
      class StereoSpecie
        attr_reader :name

        # @param [DependentSpec] dept_spec
        def initialize(dept_spec)
          @name = dept_spec.name
          @links = LinksFixer.fix(dept_spec.links)
        end

      private

        attr_reader :links

        def matrix
          start_atom = spread_atom
          walker = Walker.new(start_atom)

        end

        def crystal_rels(atom)
          links[atom].select { |_, rel| rel.relation? && rel.belongs_to_crystal? }
        end

        def spread_atom
          links.max_by { |atom, rels| atom.lattice ? rels.size : -1 }.first
        end
      end

    end
  end
end
