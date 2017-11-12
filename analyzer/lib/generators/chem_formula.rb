module VersatileDiamond
  module Generators

    # Draws formulas of using kinetic scheme
    class ChemFormula < Base
      # Initializes formulas generator
      # @param [Organizers::AnalysisResult] analysis_result see at super same argument
      # @param [String] out_path the path where result files will be placed
      def initialize(analysis_result, out_path)
        super(analysis_result)
        @out_path = out_path
      end

      # Generates file with drawing formulas
      def generate(**)
      end

    private

      # @return [Array]
      def stereo_species
        surface_specs.map { |spec| Formula::StereoSpecie.new(spec) }
      end
    end

  end
end
