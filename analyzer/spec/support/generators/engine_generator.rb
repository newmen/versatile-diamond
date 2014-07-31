module VersatileDiamond
  module Generators
    module Support

      # Provides engine code and analysis results instances for RSpec
      module EngineGenerator
        include Organizers::SpeciesOrganizer

        # Stubs analysis results and allow to call methods with same names as keys of
        # passed hash
        #
        # @param [Hash] depts see at #stub_generator same argument
        # @return [RSpec::Mocks::Double] same as original analysis results
        def stub_results(depts)
          results = double('analysis_results')
          default_depts.merge(depts).each do |method_name, list|
            allow(results).to receive(method_name).and_return(list)
          end

          depts.each { |method_name, _| send(:"organize_#{method_name}", results) }

          results
        end

        # Iterates all dependents, analyse them, stub generator by omitted analysis
        # results and get it
        #
        # @param [Hash] depts the hash where keys are analysis result method names
        #   and values are arrays of wrapping concepts
        # @return [EngineCode] the engine code generator
        def stub_generator(depts)
          EngineCode.new(stub_results(depts), '/tmp')
        end

      private

        # Provides default concept methods value
        # @return [Hash] the hash where each value is nil
        def default_depts
          hash = [:base_specs, :specific_specs].map { |c| [c, nil] }
          Hash[hash]
        end

        # Organizes dependencies between wrapped base species
        def organize_base_specs(res)
          organize_base_specs_dependencies!(res.base_specs)
        end

        # Organizes dependencies between wrapped specific species
        def organize_specific_specs(res)
          base_cache = res.base_specs ? make_cache(res.base_specs) : {}
          organize_specific_spec_dependencies!(base_cache, res.specific_specs)
        end
      end
    end
  end
end
