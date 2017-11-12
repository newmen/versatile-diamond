module VersatileDiamond
  module Generators
    module Formula

      # Knows how the specie located at the space
      class StereoSpecie
        class << self
          # @param [Hash] links
          # @return [Atom]
          def spread_atom(links)
            links.max_by { |atom, rels| atom.lattice ? rels.size : -1 }.first
          end
        end

        attr_reader :name

        # @param [DependentSpec] dept_spec
        def initialize(dept_spec)
          @name = dept_spec.name
          @links = LinksFixer.remove_excess(dept_spec.links)
          @start_atom = self.class.spread_atom(@links)
          @mx = CrystalMatrix.new(@start_atom)
        end

        # @return [Hash]
        def atoms_and_bonds
          is_matrix_configured = walk(mx.node_with(start_atom))
          if is_matrix_configured
            Space.new(mx, links).items
          else
            raise "Space matrix cannot be configured for #{name} specie"
          end
        end

      private

        attr_reader :links, :start_atom, :mx

        # @param [MatrixNode] from_node
        # @return [Boolean]
        def walk(from_node)
          crystal_rels(from_node.atom).all? do |nbr_atom, rel|
            nbr_node = mx.node_with(nbr_atom)
            mx.steps_by(rel, from_node).any? do |to_node|
              if nbr_node
                to_node == nbr_node
              elsif to_node.atom
                false
              else
                walk(to_node.place!(nbr_atom)) || to_node.reset!
              end
            end
          end
        end

        # @param [Atom] atom
        # @return [Array]
        def crystal_rels(atom)
          links[atom].select { |_, rel| rel.relation? && rel.belongs_to_crystal? }
        end
      end

    end
  end
end
