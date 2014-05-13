module VersatileDiamond
  module Generators

    # Provides methods for drawing atom properties and dependencies between them
    class AtomsSpeciesTree < Tree
      include SpeciesGraphGenerator
      include AtomsGraphGenerator
      include AtomDependenciesGenerator

      # Generates a graph image file
      # @option [Boolean] :base_specs species will be shown an graph or not
      # @option [Boolean] :spec_specs specific species will be shown an graph or not
      # @option [Boolean] :no_includes are includes not will be shown at graph or not
      def generate(base_specs: false, spec_specs: false, term_specs: false,
        no_includes: false)

        if base_specs || spec_specs || term_specs
          atoms_of_base_specs(no_includes: no_includes) if base_specs
          atoms_of_specific_specs(no_includes: no_includes) if spec_specs
          atoms_for_termination_specs if term_specs
        else
          classify_atoms_of_specs(surface_specs)
        end

        draw_atom_dependencies unless no_includes

        generate_graph
      end

    private

      # Do classification of atoms of each of passed species
      # @param [Array] specs the array of analyzing species
      def classify_atoms_of_specs(specs)
        specs.each { |s| classifier.classify(s) }
      end

    end

  end
end
