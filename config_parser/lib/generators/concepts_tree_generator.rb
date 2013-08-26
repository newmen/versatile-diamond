require 'graphviz'

module VersatileDiamond
  module Generators

    class ConceptsTreeGenerator
      SPECIFIC_SPEC_COLOR = 'blue'
      TERMINATION_SPEC_COLOR = 'chocolate'
      WHERE_COLOR = 'darkviolet'

      TYPICAL_REACTION_COLOR = 'darkgreen'
      TYPICAL_REACTION_SECOND_SOURCE_EDGE_COLOR = 'gray'
      REACTION_DEPENDING_EDGE_COLOR = 'red'

      def initialize(filename, ext = 'png', draw_second_source_deps: false)
        @filename = "#{filename}.#{ext}"
        @ext = ext.to_sym

        @draw_second_source_deps = draw_second_source_deps

        @graph = GraphViz.new(:G, type: :digraph)

        @base_specs = Tools::Chest.all(:gas_spec, :surface_spec)
        @specific_specs = Tools::Chest.all(:specific_spec)
        @termination_specs = Tools::Chest.all(:active_bond, :atomic_spec)
        @wheres = Tools::Chest.all(:where).reduce([]) do |acc, hash|
          acc + hash.values
        end

        @ubiquitous_reactions = Tools::Chest.all(:ubiquitous_reaction)
        @typical_reactions = Tools::Chest.all(:reaction)
        @lateral_reactions = Tools::Chest.all(:lateral_reaction)
      end

      def generate
        # draw calls order is important!
        draw_specs
        draw_specific_specs
        draw_termination_specs
        draw_wheres

        draw_typical_reactions
        draw_ubiquitous_reactions
        draw_lateral_reactions

        draw_reactions_dependencies

        @graph.output(@ext => @filename)
      end

    private

      def draw_specs
        @spec_to_nodes = @base_specs.each_with_object({}) do |spec, hash|
          hash[spec] = @graph.add_nodes(spec.name.to_s)
        end

        @base_specs.each do |spec|
          next unless spec.parent
          @graph.add_edges(@spec_to_nodes[spec], @spec_to_nodes[spec.parent])
        end
      end

      def draw_specific_specs
        setup_lambda = -> x { x.color = SPECIFIC_SPEC_COLOR }

        @sp_specs_to_nodes = @specific_specs.each_with_object({}) do |ss, hash|
          ss_name = ss.full_name.sub(/\A([^(]+)(.+)\Z/, "\\1\n\\2")
          node = @graph.add_nodes(ss_name)
          node.set(&setup_lambda)
          hash[ss] = node
        end

        @specific_specs.each do |ss|
          node = @sp_specs_to_nodes[ss]
          parent = ss.parent
          next unless parent || @spec_to_nodes

          edge = if parent
              @graph.add_edges(node, @sp_specs_to_nodes[parent])
            elsif (base = @spec_to_nodes[ss.spec])
              @graph.add_edges(node, base)
            end
          edge.set(&setup_lambda)
        end
      end

      def draw_termination_specs
        @sp_specs_to_nodes ||= {}
        @termination_specs.each do |ts|
          node = @graph.add_nodes(ts.name.to_s)
          node.set { |e| e.color = TERMINATION_SPEC_COLOR }
          @sp_specs_to_nodes[ts] = node
        end
      end

      def draw_wheres
        @wheres_to_nodes = @wheres.each_with_object({}) do |where, hash|
          multiline_name = multilinize(where.description, limit: 8)
          node = @graph.add_nodes(multiline_name)
          node.set { |n| n.color = WHERE_COLOR }
          hash[where] = node
        end

        @wheres.each do |where|
          node = @wheres_to_nodes[where]
          if (parents = where.parents)
            parents.each do |parent|
              @graph.add_edges(node, @wheres_to_nodes[parent]).set do |e|
                e.color = WHERE_COLOR
              end
            end
          end

          next unless @spec_to_nodes
          where.specs.each do |spec|
            spec_node = @spec_to_nodes[spec]
            @graph.add_edges(node, spec_node).set { |e| e.color = WHERE_COLOR }
          end
        end
      end

      def draw_typical_reactions
        @typical_reacts_to_nodes = {}
        draw_reactions(@typical_reactions) do |reaction, node|
          @typical_reacts_to_nodes[reaction] = node
          remember_more_complexes(reaction)
        end
      end

      def draw_ubiquitous_reactions
        @ubiq_reacts_to_nodes = {}
        draw_reactions(@ubiquitous_reactions) do |reaction, node|
          @ubiq_reacts_to_nodes[reaction] = node
        end
      end

      def draw_lateral_reactions
        not_draw_spec_edges = -> reaction do
          @react_to_more_complex && @react_to_more_complex[reaction]
        end

        @lateral_reactions.sort_by! { |reaction| reaction.size }

        @lateral_reacts_to_nodes = {}
        draw_reactions(@lateral_reactions, not_draw_spec_edges) do |reaction, node|
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

      def draw_reactions_dependencies
        if @ubiq_reacts_to_nodes && @typical_reacts_to_nodes
          draw_reactions_depending_edges(@ubiquitous_reactions,
            @ubiq_reacts_to_nodes, @typical_reacts_to_nodes)
        end

        if @typical_reacts_to_nodes && @lateral_reacts_to_nodes
          draw_reactions_depending_edges(@typical_reactions,
            @typical_reacts_to_nodes, @lateral_reacts_to_nodes)
        end

        if @lateral_reacts_to_nodes
          draw_reactions_depending_edges(@lateral_reactions,
            @lateral_reacts_to_nodes, @lateral_reacts_to_nodes)
        end
      end

      def draw_reactions(reactions, not_draw_spec_edges = nil, &block)
        reactions.each do |reaction|
          multiline_name = multilinize(reaction.name)

          node = @graph.add_nodes(multiline_name)
          node.set { |n| n.color = TYPICAL_REACTION_COLOR }

          block[reaction, node] if block_given?

          next if not_draw_spec_edges && not_draw_spec_edges[reaction]

          draw_edges_to_specific_specs(
            node, reaction.source, TYPICAL_REACTION_COLOR)
        end
      end

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

      def draw_edges_to_specific_specs(reaction_node, specific_specs, color)
        return unless @sp_specs_to_nodes

        color = TYPICAL_REACTION_COLOR
        draw_edge_to = -> spec do
        if (spec_node = @sp_specs_to_nodes[spec])
            @graph.add_edges(reaction_node, spec_node).set do |e|
              e.color = color
            end
          end
        end

        draw_edge_to[specific_specs.shift]

        return unless @draw_second_source_deps
        color = TYPICAL_REACTION_SECOND_SOURCE_EDGE_COLOR
        specific_specs.each(&draw_edge_to)
      end

      def remember_more_complexes(reaction)
        @react_to_more_complex ||= {}
        reaction.more_complex.each do |mc|
          @react_to_more_complex[mc] = reaction
        end
      end

      def multilinize(text, limit: 13)
        words = text.split(/\s+/)
        splitted_text = ['']
        until words.empty?
          splitted_text << '' if splitted_text.last.size > limit
          splitted_text.last << ' ' if splitted_text.last.size > 0
          splitted_text.last << words.shift
        end
        splitted_text.join("\n")
      end
    end

  end
end
