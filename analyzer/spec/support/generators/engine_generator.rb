module VersatileDiamond
  module Generators
    module Support

      # Provides engine code and analysis results instances for RSpec
      module EngineGenerator
        include Organizers::Support::PseudoResults

        # Iterates all dependents, analyse them, stub generator by omitted analysis
        # results and get it
        #
        # @param [Hash] depts the hash where keys are analysis result method names
        #   and values are arrays of wrapping concepts
        # @return [EngineCode] the engine code generator
        def stub_generator(depts)
          EngineCode.new(stub_results(depts), '/tmp')
        end
      end
    end
  end
end
