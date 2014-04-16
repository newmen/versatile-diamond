module VersatileDiamond
  module Generators

    # Implements methods for generating graph
    # @abstract
    class Tree < Base
      include GraphGenerator

      # Initializes the tree generator object
      # @param [Organizers::AnalysisResult] analysis_result see at super same argument
      # @param [String] filename the name of result image file
      # @param [String] ext the extention of result image file
      def initialize(analysis_result, filename, ext = 'png')
        super(analysis_result)
        init_graph(filename, ext)
      end
    end

  end
end
