module VersatileDiamond
  module Generators
    module Support

      # Provides engine code and analysis results instances for RSpec
      module EngineGenerator
        include Organizers::SpeciesOrganizer

        # Iterates all concepts, analyse them, stub generator by omitted analysis
        # results and get it
        #
        # @param [Hash] concepts the hash where keys are analysis result method names
        #   and values are arrays of wrapping concepts
        # @return [EngineCode] the engine code generator
        def stub_generator(concepts)
          res = double('analysis_results')
          default_concepts.merge(concepts).each do |method_name, list|
            wrapped_list = list && wrap(list)
            allow(res).to receive(method_name).and_return(wrapped_list)
          end

          concepts.each { |method_name, _| send(:"organize_#{method_name}", res) }

          EngineCode.new(res, '/tmp')
        end

      private

        DEP_CLASSES_MIRROR = {
          Concepts::GasSpec => Organizers::DependentBaseSpec,
          Concepts::SurfaceSpec => Organizers::DependentBaseSpec,
          Concepts::DuppableSurfaceSpec => Organizers::DependentBaseSpec,
          Concepts::SpecificSpec => Organizers::DependentSpecificSpec,
        }.freeze

        # Provides default concept methods value
        # @return [Hash] the hash where each value is nil
        def default_concepts
          hash = [:base_specs, :specific_specs].map { |c| [c, nil] }
          Hash[hash]
        end

        # Wraps any concepts
        # @param [Array] concepts the wrappable concepts
        # @return [Array] the wrapped concepts
        def wrap(concepts)
          concepts.map { |c| DEP_CLASSES_MIRROR[c.class].new(c) }
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
