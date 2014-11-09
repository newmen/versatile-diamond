module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for clean links of reaction and group them by parameters
        # of relations
        class ReactionGroupedNodes < BaseGroupedNodes
          # Initizalize grouper by reaction class code generator
          # @param [EngineCode] generator the major code generator
          # @param [TypicalReaction] reaction from which grouped graph will be gotten
          def initialize(generator, reaction)
            super(generator)
            @reaction = reaction

            @atoms_to_nodes = {}
            @specs_to_uniques = {}

            @_big_links_graph, @_small_links_graph = nil
          end

        private

          def big_links_graph
            @_big_links_graph ||= transform_links(@reaction.original_links)
          end

          def small_links_graph
            @_small_links_graph ||= transform_links(@reaction.clean_links)
          end

          def get_node(spec_atom)
            spec, atom = spec_atom
            return @atoms_to_nodes[atom] if @atoms_to_nodes[atom]

            specie = get_unique_specie(spec)
            @atoms_to_nodes[atom] = Node.new(specie.original, specie, atom)
          end

          # Makes unique specie instance from passed spec
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   spec by which the unique algorithm specie will be maked
          # @return [UniqueSpecie] the wrapped specie code generator
          def get_unique_specie(spec)
            return @specs_to_uniques[spec] if @specs_to_uniques[spec]
            specie = specie_class(spec)
            @specs_to_uniques[spec] = UniqueSpecie.new(specie, specie.spec)
          end

          # Detects relation between passed nodes
          # @param [Array] nodes the array with two nodes between which the relation
          #   will be detected
          # @return [Concepts::Bond] the relation between atoms from passed nodes
          def relation_between(*nodes)
            specs_atoms = nodes.map { |n| [n.uniq_specie.spec.spec, n.atom] }
            @reaction.relation_between(*specs_atoms)
          end
        end

      end
    end
  end
end
