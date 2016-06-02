module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The context for units of reaction applying algoritnm builder
        class ChangesContextProvider
          # @param [Hash] links
          # @param [Array] main
          # @param [Array] full
          def initialize(links, main, full)
            @links = links
            @main = main
            @full = full

            @prd_to_src_mirror = @full.map { |src| [src.product.spec_atom, src] }.to_h
            @src_mirror = @full.map { |src| [src.spec_atom, src] }.to_h
            @prd_mirror = @full.map { |src| [src.product.spec_atom, src.product] }.to_h

            @cache = {}
            @_phase_changes = nil
          end

          # @return [Array]
          def phase_changes
            @_phase_changes ||=
              @main.reject { |src| src.lattice == src.product.lattice }
          end

          # @return [Array]
          def significant
            neighbours = phase_changes.flat_map { |node| neighbours_of(node).first }
            neighbours.reject(&method(:main?)).uniq
          end

          # @param [Nodes::SourceNode] node
          # @return [Array]
          def latticed_neighbours_of(node)
            return @cache[node] if @cache[node]
            latticed_nrps = latticed_relation_params_of(node)
            main_nrps = latticed_nrps.select { |nbr, _| main?(nbr) }
            neighbours = best_neighbours(main_nrps)
            neighbours = best_neighbours(latticed_nrps) if neighbours.size < 2
            # TODO: logic of neighbours selection depends from diamond crystal lattice!
            if neighbours.size < 2
              raise ArgumentError, "Cannot find neighbours for node #{node.inspect}"
            else
              @cache[node] = neighbours
            end
          end

          # @param [Nodes::ChangeNode] node
          # @return [Array]
          def direct_neighbours_of(node)
            mirror = @full.include?(node) ? @src_mirror : @prd_mirror
            neighbour_spec_atoms(node).map { |sa| mirror[sa] }
          end

        private

          # @param [Nodes::SourceNode] node
          # @return [Boolean]
          def main?(node)
            @main.include?(node)
          end

          # @param [Array] relations
          # @return [Array]
          def best_neighbours(relations)
            groups = relations.group_by(&:last)
            max_group = groups.max_by { |_, group| group.size }
            [max_group.last.map(&:first), max_group.first]
          end

          # @param [Nodes::ChangeNode] node
          # @return [Array]
          def latticed_relation_params_of(node)
            neighbour_spec_atoms(node.product).each_with_object([]) do |sa, acc|
              nbr = @prd_to_src_mirror[sa]
              if nbr.lattice
                rel = relation_between(node, nbr)
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

          # @param [Array] nodes
          # @return [Concept::Bond]
          def relation_between(*nodes)
            a, b = nodes.map(&:spec_atom)
            result = @links[a].find { |sa, _| sa == b }
            result && result.last
          end
        end

      end
    end
  end
end
