module VersatileDiamond
  module Generators

    # Implements methods for generating graph of general concepts dependencies
    class SpeciesReactionsTree < Tree
      include SpeciesGraphGenerator
      include ReactionsGraphGenerator

      # Generates a graph image file
      # @option [Boolean] :no_base_specs if set to true then base species doesn't shown
      # @option [Boolean] :no_spec_specs show or not specific species set
      # @option [Boolean] :no_term_specs show or not termination species set
      # @option [Boolean] :no_chunks show or not termination species set
      # @option [Boolean] :no_reactions if set to true then reactions doesn't shown
      def generate(no_base_specs: false, no_spec_specs: false, no_term_specs: false,
        no_chunks: false, no_reactions: false, products: false)

        # draw calls order is important!
        draw_base_specs unless no_base_specs
        draw_specific_specs unless no_spec_specs
        draw_termination_specs unless no_term_specs
        draw_chunks unless no_chunks

        unless no_reactions
          draw_typical_reactions
          draw_ubiquitous_reactions
          draw_lateral_reactions

          draw_all_reactions_deps(products: products)
        end

        generate_graph
      end
    end

  end
end
