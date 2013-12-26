module VersatileDiamond
  module Generators

    # Implements methods for generating graph of general concepts dependencies
    class ConceptsTreeGenerator < GraphGenerator

      WHERE_COLOR = 'darkviolet'

      TYPICAL_REACTION_COLOR = 'darkgreen'
      TYPICAL_REACTION_SECOND_SOURCE_EDGE_COLOR = 'gray'
      REACTION_DEPENDING_EDGE_COLOR = 'red'

      # Initialize a new instance of generator
      # @param [String] filename the name of result image file
      # @param [String] ext the extention of result image file
      # @option [Boolean] :draw_second_source_deps if set then reaction
      #   dependency from second source spec will show on dependencies tree
      # @override
      def initialize(filename, ext = 'png', draw_second_source_deps: false)
        super(filename, ext)
        @draw_second_source_deps = draw_second_source_deps
      end

      # Generates a graph image file
      # @option [Boolean] :no_specs if set to true then base species doesn't
      #   shown
      # @option [Boolean] :no_spec_specs if set to true then specific species
      #   doesn't shown
      # @option [Boolean] :no_reactions if set to true then reactions doesn't
      #   shown
      # @override
      def generate(no_specs: false, no_spec_specs: false, no_reactions: false)
        # draw calls order is important!
        draw_specs if !no_specs
        draw_specific_specs if !no_spec_specs
        draw_termination_specs
        draw_wheres

        if !no_reactions
          draw_typical_reactions
          draw_ubiquitous_reactions
          draw_lateral_reactions
        end

        draw_reactions_dependencies

        super()
      end

    private

      # Draws where objects and dependencies between them, and also will
      # draw dependencies from specific species
      def draw_wheres
        @wheres_to_nodes = wheres.each_with_object({}) do |where, hash|
          multiline_name = multilinize(where.description, limit: 8)
          node = @graph.add_nodes(multiline_name)
          node.set { |n| n.color = WHERE_COLOR }
          hash[where] = node
        end

        wheres.each do |where|
          node = @wheres_to_nodes[where]
          if (parents = where.parents)
            parents.each do |parent|
              @graph.add_edges(node, @wheres_to_nodes[parent]).set do |e|
                e.color = WHERE_COLOR
              end
            end
          end

          next unless @sp_specs_to_nodes
          where.specs.each do |spec|
            spec_node = @spec_to_nodes[spec] || @sp_specs_to_nodes[spec]
            @graph.add_edges(node, spec_node).set { |e| e.color = WHERE_COLOR }
          end
        end
      end

      # Draws typical reactions and dependencies between them, and also will
      # draw dependencies from reactants
      def draw_typical_reactions
        @typical_reacts_to_nodes = {}
        draw_reactions(typical_reactions) do |reaction, node|
          @typical_reacts_to_nodes[reaction] = node
          remember_more_complexes(reaction)
        end
      end

      # Draws ubiquitous reactions, and also will draw dependencies from
      # reactants
      def draw_ubiquitous_reactions
        @ubiq_reacts_to_nodes = {}
        draw_reactions(ubiquitous_reactions) do |reaction, node|
          @ubiq_reacts_to_nodes[reaction] = node
        end
      end

      # Draws lateral reactions and dependencies between them, and also will
      # draw dependencies from reactants
      def draw_lateral_reactions
        not_draw_spec_edges = -> reaction do
          @react_to_more_complex && @react_to_more_complex[reaction]
        end

        lateral_reactions.sort_by!(&:size)

        @lateral_reacts_to_nodes = {}
        draw_reactions(lateral_reactions, not_draw_spec_edges) do
          |reaction, node|

          @lateral_reacts_to_nodes[reaction] = node
          remember_more_complexes(reaction)

          if @wheres_to_nodes
            reaction.wheres.each do |where|
              where_node = @wheres_to_nodes[where]
              @graph.add_edges(node, where_node).set do |e|
                e.color = WHERE_COLOR
              end
            end
          end
        end
      end

      # Draws dependencies between reactions
      def draw_reactions_dependencies
        if @ubiq_reacts_to_nodes && @typical_reacts_to_nodes
          draw_reactions_depending_edges(ubiquitous_reactions,
            @ubiq_reacts_to_nodes, @typical_reacts_to_nodes)
        end

        if @typical_reacts_to_nodes && @lateral_reacts_to_nodes
          draw_reactions_depending_edges(typical_reactions,
            @typical_reacts_to_nodes, @lateral_reacts_to_nodes)
        end

        if @lateral_reacts_to_nodes
          draw_reactions_depending_edges(lateral_reactions,
            @lateral_reacts_to_nodes, @lateral_reacts_to_nodes)
        end
      end

      # Draws reactions and dependencies between reactants
      # @param [Array] reactions the array of reactions that will be drawed
      # @param [Proc] not_draw_spec_edges the lambda that return boolean value
      #   if not necessary draw dependencies from reactants
      # @yield [Array] do someting with reaction and their node
      def draw_reactions(reactions, not_draw_spec_edges = nil, &block)
        reactions.each do |reaction|
          multiline_name = multilinize(reaction.name)

          node = @graph.add_nodes(multiline_name)
          node.set { |n| n.color = TYPICAL_REACTION_COLOR }

          block[reaction, node] if block_given?

          next if not_draw_spec_edges && not_draw_spec_edges[reaction]

          draw_edges_to_specific_specs(node, reaction.source)
        end
      end

      # Draws dependencies between reactions
      # @param [Array] reactions the reactions for which will draw dependencies
      #   from more complex reactions
      # @param [Hash] current_to_nodes the hash where keys is reactions for
      #   which and dependencies will draw, and values is correspond nodes
      # @param [Hash] child_to_nodes the hash where keys is dependend reactions
      #   and values is correspond nodes
      def draw_reactions_depending_edges(reactions, current_to_nodes, child_to_nodes)
        reactions.each do |reaction|
          next if reaction.more_complex.empty?

          node = current_to_nodes[reaction]
          reaction.more_complex.each do |child|
            child_node = child_to_nodes[child]
            @graph.add_edges(node, child_node).set do |e|
              e.color = REACTION_DEPENDING_EDGE_COLOR
            end
          end
        end
      end

      # Draws dependencies of reaction from reactants
      # @param [Node] reaction_node the node of reaction
      # @param [Array] specific_specs the arrya of dependent specific specs
      def draw_edges_to_specific_specs(reaction_node, specific_specs)
        return unless @sp_specs_to_nodes

        draw_edge_to = -> spec do
        if (spec_node = @sp_specs_to_nodes[spec])
            @graph.add_edges(reaction_node, spec_node).set do |e|
              color = spec.is_gas? ?
                TYPICAL_REACTION_SECOND_SOURCE_EDGE_COLOR :
                TYPICAL_REACTION_COLOR

              e.color = color
            end
          end
        end

        specific_specs = specific_specs.sort { |a, b| b.size <=> a.size }
        draw_edge_to[specific_specs.shift]

        return unless @draw_second_source_deps
        specific_specs.each(&draw_edge_to)
      end

      # Remembers more complex reactions for passed reaction
      # @param [UbiquitousReaction] reaction the reaction which is aware of
      #   their more complex analogs
      def remember_more_complexes(reaction)
        @react_to_more_complex ||= {}
        reaction.more_complex.each do |mc|
          @react_to_more_complex[mc] = reaction
        end
      end
    end

  end
end
