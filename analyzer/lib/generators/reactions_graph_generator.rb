module VersatileDiamond
  module Generators

    # Provides methods for reactions graph generation
    module ReactionsGraphGenerator

      UBIQUITOUS_REACTION_COLOR = 'lightblue'
      TYPICAL_REACTION_COLOR = 'darkgreen'
      LATERAL_REACTION_COLOR = 'lightpink'
      CHUNK_COLOR = 'darkviolet'

      REACTION_DEPENDENT_EDGE_COLOR = 'red'

    private

      # Draws chunks and dependencies between them, and also will
      # draw dependencies from specific species
      def draw_chunks
        @chunk_to_node ||= {}
        name_method = method(:multilinize)
        setup_lambda = -> x { x.color = CHUNK_COLOR }

        add_nodes_to(
          @chunk_to_node, chunks, method(:same_key), name_method, &setup_lambda)

        multi_deps(:parents, chunks, method(:chunk_node), &setup_lambda)
        if @spec_to_node
          multi_deps(:specs, chunks.select { |ch| ch.parents.empty? },
            method(:chunk_node), method(:spec_node), &setup_lambda)
        end
      end

      # Draws ubiquitous reactions, and also will draw dependencies from
      # reactants
      def draw_ubiquitous_reactions
        draw_reactions(ubiquitous_reactions, &method(:ubiquitous_setup))
      end

      # Draws typical reactions and dependencies between them, and also will
      # draw dependencies from reactants
      def draw_typical_reactions
        draw_reactions(typical_reactions, &method(:typical_setup))
      end

      # Draws lateral reactions and dependencies between them, and also will
      # draw dependencies from reactants
      def draw_lateral_reactions
        setup_lambda = method(:lateral_setup)
        draw_reactions(lateral_reactions, &setup_lambda)
        if @chunk_to_node
          mono_dep(:chunk, lateral_reactions,
            method(:reaction_node), method(:chunk_node), &setup_lambda)
        end
      end

      # Draws reactions and dependencies between reactants
      # @param [Array] reactions the array of reactions that will be drawed
      # @yield [Array] do someting with each reaction node
      def draw_reactions(reactions, &setup_block)
        @reaction_to_node ||= {}
        name_method = method(:multilinize)

        add_nodes_to(
          @reaction_to_node, reactions, method(:same_key), name_method, &setup_block)
      end

      # Draws dependencies between reactions
      def draw_all_reactions_deps
        multicomplexes_deps(ubiquitous_reactions, &method(:ubiquitous_setup))
        multicomplexes_deps(typical_reactions, &method(:typical_setup))
        multicomplexes_deps(lateral_reactions, &method(:lateral_setup))
      end

      # Draw dependencies between reactions and their more complex analogies and to
      # source reaction specs
      #
      # @param [Array] reactions the reactions set dependencies for which will be show
      # @yield [Edge] do with each drawn edge
      def multicomplexes_deps(reactions, &setup_block)
        complexes_setup = -> x { x.color = REACTION_DEPENDENT_EDGE_COLOR }
        multi_deps(:children, reactions, method(:reaction_node), &complexes_setup)

        if @spec_to_node
          multi_deps(:source, reactions.select { |rc| !rc.parent || rc.local? },
            method(:reaction_node), method(:spec_node), &setup_block)
        end
      end

      # Provides methods for setup correspond graph items
      %w(ubiquitous typical lateral).each do |name|
        # @param [Node | Edge] x the setable graph item
        define_method(:"#{name}_setup") do |x|
          x.color = eval("#{name.upcase}_REACTION_COLOR")
        end
      end

      # Gets the entity as result
      # @param [Object] entity the returned entity
      # @return [Object] the passed entity
      def same_key(entity)
        entity
      end

      # Gets chunk node from internal chunk to node cache
      # @param [Organizers::DrawableChunk] chunk for which node will returned
      # @return [Node] the result chunk node
      def chunk_node(chunk)
        @chunk_to_node[chunk]
      end

      # Gets reaction node from internal reaction to node cache
      # @param [Organizers::DependentReaction] reaction for which node will returned
      # @return [Node] the result reaction node
      def reaction_node(reaction)
        @reaction_to_node[reaction]
      end
    end

  end
end
