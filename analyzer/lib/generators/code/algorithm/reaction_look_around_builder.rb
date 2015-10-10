module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building reaction look around algorithm
        class ReactionLookAroundBuilder < LateralChunksAlgorithmBuilder

          # Initializes internal caches
          def initialize(*)
            super
            @_has_monolite_sidepiece = nil
          end

        private

          # Creates backbone of algorithm
          # @return [LookAroundBackbone] the backbone which provides ordered graph
          def create_backbone
            LookAroundBackbone.new(generator, lateral_chunks)
          end

          # Creates factory of units for algorithm generation
          # @return [LookAroundUnitsFactory] correspond units factory
          def create_factory
            LookAroundUnitsFactory.new(generator, lateral_chunks)
          end

          # Gets an unit from which the search begins
          # @return [BaseUnit] the unit by which entry variables will be initialized
          def initial_unit
            factory.make_unit(backbone.action_nodes)
          end

          # Orders entry nodes for case when we must nest one check to another
          def ordered_entry_nodes
            backbone.entry_nodes.sort do |a, b|
              if a.size == b.size
                a.max <=> b.max # reversed by nodes default ordering
              else
                b.size <=> a.size
              end
            end
          end

          # Collects procedures by which the algorithm will be combined
          # @return [Array] the array of all procedures with end nodes
          def collect_procs
            ordered_entry_nodes.flat_map(&method(:combine_algorithm))
          end

          # Builds body of algorithm
          # @return [String] the string with cpp code
          def body
            if monolite_sidepiece?
              nested_cmb(collect_procs)
            else
              sequental_cmb(collect_procs)
            end
          end

          # Provides nested combination of entry nodes
          # @param [Array] procs by which the algorithm will be combined
          # @return [String] the string with cpp code
          def nested_cmb(procs)
            all_procs = procs.flat_map { |np, cps| [np] + cps.map(&:first) }
            last_creator = procs.last.last.last.last
            reduce_procs(all_procs) { last_creator.lines }.call
          end

          # Provides sequental combination of entry nodes
          # @param [Array] procs by which the algorithm will be combined
          # @return [String] the string with cpp code
          def sequental_cmb(procs)
            procs.reduce('') do |acc, (nbr_proc, crt_procs)|
              crt = crt_procs.last.last
              func = reduce_procs([nbr_proc] + crt_procs.map(&:first)) { crt.lines }
              acc + func.call
            end
          end

          # Build look around algorithm by combining procs that occured by walking
          # on backbone graph ordered from nodes
          #
          # @param [Array] nodes from which walking will occure
          # @yield [Array] do with neighbours nodes
          # @return [Array] the list of procedures with end nodes
          def combine_algorithm(nodes)
            checking_rels(nodes).map do |nbrs, rel_params|
              [relations_proc(nodes, nbrs, rel_params), creation_proc(nbrs)]
            end
          end

          # Gets the lines by which the lateral reaction will be created in algorithm
          # @param [Array] side_nodes the list of nodes from which the lateral reaction
          #   will be created
          # @return [Array] the list of two items with procedure and creators
          def creation_proc(side_nodes)
            rwsps = reaction_with_sidepieces(side_nodes)
            checker = factory.checker(*rwsps)
            func = -> &block { checker.define_and_check(&block) }
            [func, rwsps]
          end

          # Gets the instances of lateral reaction and sidepiece species which
          # available on ordered graph from passed nodes
          #
          # @param [Array] the pair where first is lateral reaction and the second is
          #   the list of sidepiece species which are additional reactants
          def reaction_with_sidepieces(nodes)
            groups = reactions_with_species(nodes).group_by(&:first)
            result = groups.map { |reaction, pairs| [reaction, pairs.map(&:last)] }

            if result.size > 1
              fail "Can't process nodes with different lateral chunks and species"
            end

            result.first
          end

          # Gets the list of pairs of lateral reaction and specie which uses in it
          # @param [Array] nodes by which the reaction will detected
          # @return [Array] the list of reation-specie pairs
          def reactions_with_species(nodes)
            nodes.map(&method(:make_reaction_specie_pair))
          end

          # Creates a pair of reaction with unique sidepiece
          # @param [ReactantNode] node by which the pair will be created
          # @return [Array] the array with two items
          def make_reaction_specie_pair(node)
            [
              lateral_chunks.select_reaction(node.spec_atom),
              OtherSideSpecie.new(node.uniq_specie)
            ]
          end

          # Checks that entry nodes are bonded with nodes with same sidepiece specie
          # but with different atoms of it
          #
          # @return [Boolean] has monolite sidepiece specie or not
          def monolite_sidepiece?
            all_rels = backbone.final_graph.select do |nodes, _|
              backbone.entry_nodes.include?(nodes)
            end

            all_nbrs = all_rels.values.map { |rels| rels.flat_map(&:first) }
            all_sas = all_nbrs.map { |nbrs| nbrs.map(&:spec_atom) }
            all_sas.each_cons(2).any? do |sas1, sas2|
              sas1.any? do |spec, atom|
                sas2.any? { |s, a| spec == s && atom != a }
              end
            end
          end
        end

      end
    end
  end
end
