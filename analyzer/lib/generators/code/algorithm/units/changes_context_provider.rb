module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm::Units

        # The context for units of reaction applying algoritnm builder
        class ChangesContextProvider
          include Modules::SpecLinksAdsorber

          # @param [Hash] reaction
          # @param [Array] main
          # @param [Array] full
          def initialize(reaction, main, full)
            @main = main
            @full = full

            @prd_to_src_mirror = @full.map { |src| [src.product.spec_atom, src] }.to_h
            @src_mirror = @full.map { |src| [src.spec_atom, src] }.to_h
            @prd_mirror = @full.map { |src| [src.product.spec_atom, src.product] }.to_h

            positions = reaction.reaction.reaction.links
            surface_products =
              @main.map(&:product).reject(&:gas?).map(&:spec_atom).map(&:first).uniq
            @product_links = collaps(adsorb_links(positions, surface_products))
            @source_links = collaps(reaction.links)

            @_significant_neighbours = {}
            @_phase_changes = nil
          end

          # @return [Array]
          def phase_changes
            @_phase_changes ||= @main.select { |src| src.transit? || src.switch? }
          end

          # @return [Array]
          def significant
            significant_neighbours.reject(&method(:main?)).uniq
          end

          # @param [Nodes::SourceNode] node
          # @return [Array]
          def latticed_neighbours_of(node)
            neighbours = significant_neighbours_of(node)
            # TODO: logic of neighbours selection depends from diamond crystal lattice!
            if neighbours.size < 2
              raise ArgumentError, "Cannot find neighbours for node #{node.inspect}"
            else
              neighbours
            end
          end

          # @param [Nodes::ChangeNode] node
          # @return [Array]
          def direct_neighbours_of(node)
            mirror = @full.include?(node) ? @src_mirror : @prd_mirror
            neighbour_spec_atoms(node).map(&mirror.public_method(:[]))
          end

          # @param [Array] nodes
          # @return [Concept::Bond] or nil
          def relation_between_sources(*nodes)
            relation_between_in(@source_links, nodes)
          end

          # @param [Array] nodes
          # @return [Concept::Bond] or nil
          def relation_between_products(*nodes)
            relation_between_in(@product_links, nodes.map(&:product))
          end

        private

          # @param [Nodes::SourceNode] node
          # @return [Boolean]
          def main?(node)
            @main.include?(node)
          end

          # @return [Array]
          def significant_neighbours
            phase_changes.reduce([]) do |acc, node|
              acc + significant_neighbours_of(node)
            end
          end

          # @return [Array]
          def significant_neighbours_of(node)
            return @_significant_neighbours[node] if @_significant_neighbours[node]
            latticed_nrps = latticed_relation_params_of(node)
            main_nrps = latticed_nrps.select { |nbr, _| main?(nbr) }
            neighbours = best_neighbours(main_nrps)
            neighbours = best_neighbours(latticed_nrps) if neighbours.size < 2
            @_significant_neighbours[node] = neighbours.size < 2 ? neighbours : []
          end

          # @param [Array] relations
          # @return [Array]
          def best_neighbours(relations)
            if relations.empty?
              []
            else
              groups = relations.group_by(&:last)
              max_group = groups.max_by { |_, group| group.size }
              [max_group.last.map(&:first), max_group.first]
            end
          end

          # @param [Nodes::ChangeNode] node
          # @return [Array]
          def latticed_relation_params_of(node)
            neighbour_spec_atoms(node.product).each_with_object([]) do |sa, acc|
              nbr = @prd_to_src_mirror[sa]
              if nbr.lattice
                rel = relation_between_sources(node, nbr)
                acc << [nbr, rel.params] if rel && rel.exist?
              end
            end
          end

          # @param [Nodes::ChangeNode] node
          # @return [Array]
          def neighbour_spec_atoms(node)
            spec, atom = node.spec_atom
            spec.links[atom].map { |a, _| [spec, a] }
          end

          # @param [Hash] links
          # @param [Array] nodes
          # @return [Concept::Bond]
          def relation_between_in(links, nodes)
            a, b = nodes.map(&:spec_atom)
            if links[a]
              result = links[a].find { |sa, _| sa == b }
              result && result.last
            else
              nil
            end
          end

          # @param [Hash] links
          # @return [Concept::Bond]
          def collaps(links)
            links.each_with_object({}) do |(key, rels), acc|
              groups = rels.groups
              singles = groups.select(&:one?).reduce(:+) || []
              manies = groups.reject(&:one?).map(&method(:squize_multi_bond))
              acc[key] = singles + manies
            end
          end

          # @param [Array] group
          # @return [Array]
          def squize_multi_bond(group)
            keys, relations = group.transpose
            if relations.any?(&:belongs_to_crystal?)
              raise ArgumentError, 'Cannot squize crystal relations'
            else
              [keys.first, Concepts::MultiBond.new(relations.size)]
            end
          end
        end

      end
    end
  end
end
