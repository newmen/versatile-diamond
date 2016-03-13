module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The context for units of specie find algoritnm builder
        class SpecieContext < BaseContext
          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Specie] specie
          # @param [Array] ordered_backbone
          def initialize(dict, specie, ordered_backbone)
            super(dict, ordered_backbone)
            @specie = specie

            @_atoms_to_nodes = nil
          end

          # @param [Concepts::Atom | Concepts::SpecificAtom | Concepts::AtomReference]
          #   atom which symmetric analogies will be gotten
          # @return [Array]
          def symmetries_of(atom)
            @specie.symmetric_atoms(atom)
          end

          %i(atoms_nodes specie_nodes reachable_nodes_with).each do |method_name|
            # @param [Array] instances
            # @return [Array]
            # @override
            define_method(method_name) do |instances|
              replace_scopes(super(instances)).uniq
            end
          end

        private

          # @param [Array] nodes
          # @return [Array]
          def replace_scopes(nodes)
            nodes.reduce([]) do |acc, node|
              node.scope? ? (acc + node.split) : (acc << node)
            end
          end

          # @param [Array] nodes
          # @return [Array]
          def relations_of(nodes)
            specie_relations_of(nodes).map(&method(:major_relations))
          end

          # @param [Array] nodes
          # @return [Array]
          def specie_relations_of(nodes)
            spec_graph = @specie.spec.clean_links
            nodes.map { |node| spec_graph[node.atom] }
          end

          # @param [Array] rels
          # @return [Array]
          def major_relations(rels)
            rels.each_with_object([]) do |(a, r), acc|
              node = atoms_to_nodes[a]
              acc << [node, r] if node
            end
          end

          # @return [Hash]
          def atoms_to_nodes
            @_atoms_to_nodes ||=
              backbone_graph.each_with_object({}) do |(nodes, rels), acc|
                ans = ans_from(nodes) + rels.flat_map { |ns, _| ans_from(ns) }
                ans.each do |atom, node|
                  acc[atom] ||= Set.new
                  acc[atom].add(node)
                end
              end
          end

          # @param [Array] nodes
          # @return [Array]
          def ans_from(nodes)
            nodes.map { |node| [node.atom, node] }
          end
        end

      end
    end
  end
end
