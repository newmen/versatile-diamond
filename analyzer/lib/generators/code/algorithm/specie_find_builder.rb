module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building find specie algorithm
        class SpecieFindBuilder < MainFindAlgorithmBuilder
          extend Forwardable

          # Inits builder by target specie and main engine code generator
          # @param [EngineCode] generator the major engine code generator
          # @param [Specie] specie the target specie code generator
          def initialize(generator, specie)
            @specie = specie
            super(generator)
          end

          # Generates find algorithm cpp code for target specie
          # @return [String] the string with cpp code of find specie algorithm
          def build
            entry_nodes_with_elses.reduce('') do |acc, (nodes, need_else_prefix)|
              factory.reset!
              acc + body_for(nodes, need_else_prefix)
            end
          end

        private

          # Creates backbone of algorithm
          # @return [SpecieBackbone] the backbone which provides ordered graph
          def create_backbone
            SpecieBackbone.new(generator, @specie)
          end

          # Creates factory of units for algorithm generation
          # @return [SpecieUnitsFactory] correspond units factory
          def create_factory
            SpecieUnitsFactory.new(generator, @specie)
          end

          # Gets entry nodes zipped with else prefixes for many ways condition
          # @return [Array] entry nodes zipped with else prefixes
          def entry_nodes_with_elses
            anchor_nodes = backbone.entry_nodes.dup
            first_nodes = anchor_nodes.shift

            prev_props = ordered_props(first_nodes)
            anchor_nodes.each_with_object([[first_nodes, false]]) do |nodes, acc|
              curr_props = ordered_props(nodes)
              acc << [nodes, !like_others?(prev_props, curr_props)]
              prev_props = curr_props
            end
          end

          # @return [String]
          def body_for(nodes, need_else_prefix)
            unit = factory.make_unit(nodes)
            unit.first_assign!

            unit.check_existence(use_else_prefix: need_else_prefix) do
              combine_algorithm(nodes)
            end
          end

          # Collects procs of conditions for body of find algorithm
          # @param [Array] nodes by which procs will be collected
          # @return [Array] the array of procs which will combined later
          def collect_procs(nodes)
            ordered_graph_from(nodes).reduce([]) do |acc, (ns, rels)|
              acc << species_proc(ns)
              acc + accumulate_relations(ns, rels)
            end
          end

          # @return [Proc] lazy calling for check species unit method
          def species_proc(nodes)
            unit = factory.make_unit(nodes)
            -> &block { unit.check_species(&block) }
          end

          # Collets atom properties from passed nodes and orders them
          # @param [Array] nodes from which the atom properties collects
          # @return [Array] the ordered list of atom_properties
          def ordered_props(nodes)
            nodes.sort.map(&:properties)
          end

          # Checks that all small props can be a part of big props. Both passed lists
          # should be ordered (because permutation did not done, just zip two lists)!
          #
          # @param [Array] big_props which should includes small props
          # @param [Array] small_props which should contains in big props
          # @return [Boolean] all small props included in all big props or not
          def like_others?(big_props, small_props)
            big_props.size == small_props.size &&
              big_props.zip(small_props).all? do |both|
                a, b = classified_props(both)
                a.like?(b)
              end
          end

          # Gets the list of classified atom properties
          # @param [Array] list_of_props which classified analogies will be returned
          # @return [Array] the list of common classified atom properties
          def classified_props(list_of_props)
            list_of_props.map(&generator.public_method(:atom_properties))
          end
        end

      end
    end
  end
end
