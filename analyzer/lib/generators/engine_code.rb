module VersatileDiamond
  module Generators

    # Generates program code based on engine framework for each interpreted entities
    class EngineCode < Base

      # Initializes code generator
      # @param [Organizers::AnalysisResult] analysis_result see at super same argument
      # @param [String] out_path the path where result files will be placed
      def initialize(analysis_result, out_path)
        super(analysis_result)
        @out_path = out_path
      end

      public :classifier, :spec_reactions, :term_specs, :specific_specs

      def generate(**params)
        code_elements.each do |class_str|
          eval("Code::#{class_str}").new(self).generate(@out_path)
        end
      end

    private

      # Provides list of code elements the source code by which will generated
      # @return [Array] the array of names of code generator classes
      def code_elements
        %w(Handbook Env)
      end
    end

  end
end
