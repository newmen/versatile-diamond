module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for clean dependent specie and get essence of specie graph
        class SpecieGroupedNodes < BaseGroupedNodes
          extend Forwardable

          # Initizalize cleaner by specie class code generator
          # @param [EngineCode] generator the major code generator
          # @param [Specie] specie from which pure essence will be gotten
          def initialize(generator, specie)
            super(generator)
            @specie = specie

            @atoms_to_nodes = {}
            @parents_to_uniques = {}

            @_big_links_graph, @_small_links_graph = nil
          end

        private

          def_delegator :@specie, :spec

          # Makes the spec-atom nodes graph from links of target specie
          # @return [Hash] the most comprehensive graph of nodes
          def big_links_graph
            @_big_links_graph ||= transform_links(spec.clean_links)
          end

          # Makes the spec-atom nodes graph from small links of target specie
          # @return [Hash] the cutten graph of nodes
          def small_links_graph
            @_small_links_graph ||= transform_links(@specie.essence.cut_links)
          end

          # Detects correct algorithm specie by passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the algorithm specie will be got
          # @return [NoneSpecie | UniqueSpecie | SpeciesScope] the correspond algorithm
          #   specie
          def parent_specie(atom)
            parents = spec.parents_of(atom)
            if parents.empty?
              NoneSpecie.new(@specie)
            elsif parents.size == 1
              get_unique_specie(parents.first)
            else
              SpeciesScope.new(parents.map(&method(:get_unique_specie)))
            end
          end

          # Makes node for passed atom
          # @return [Node] new node which contain the correspond algorithm specie and
          #   passed atom
          def get_node(atom)
            @atoms_to_nodes[atom] ||= Node.new(@specie, parent_specie(atom), atom)
          end

          # Makes unique specie instance from passed spec
          # @param [Organizers::ProxyParentSpec] parent by which the unique algorithm
          #   specie will be maked
          # @return [UniqueSpecie] the wrapped passed specie code generator
          def get_unique_specie(parent)
            @parents_to_uniques[parent] ||=
              UniqueSpecie.new(specie_class(parent), parent)
          end

          # Detects relation between passed nodes
          # @param [Array] nodes the array with two nodes between which the relation
          #   will be detected
          # @return [Concepts::Bond] the relation between atoms from passed nodes
          def relation_between(*nodes)
            atoms = nodes.map(&:atom)
            spec.relation_between(*atoms)
          end
        end

      end
    end
  end
end
