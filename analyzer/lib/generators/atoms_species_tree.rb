module VersatileDiamond
  module Generators

    # Provides methods for drawing atom properties and dependencies between them
    class AtomsSpeciesTree < Tree
      include AtomsGraphGenerator
      include SpeciesGraphGenerator

      # Generates a graph image file
      # @option [Boolean] :base_specs species will be shown an graph or not
      # @option [Boolean] :spec_specs specific species will be shown an graph or not
      # @option [Boolean] :no_includes are includes not will be shown at graph or not
      # @option [Boolean] :no_transitions transitions between atoms not will be
      #   shown or not
      def generate(base_specs: false, spec_specs: false, term_specs: false,
        no_includes: false, no_transitions: false)

        if base_specs || spec_specs || term_specs
          draw_base_specs(no_includes: no_includes) if base_specs
          draw_specific_specs(no_includes: no_includes) if spec_specs
          draw_termination_specs if term_specs
        else
          surface_specs.each { |s| draw_atoms(classifier.classify(s)) }
        end

        draw_atom_dependencies unless no_includes
        draw_atom_transitions unless no_transitions

        generate_graph
      end
    end

  end
end
