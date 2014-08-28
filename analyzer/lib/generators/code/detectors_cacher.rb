module VersatileDiamond
  module Generators
    module Code

      # Accumulates all used symmetries detectors and creates new detector if it's not
      # presented
      class DetectorsCacher
        # Inits the cacher instance
        # @param [EngineCode] generator which will be used for getting a specie code
        #   generator
        def initialize(generator)
          @generator = generator
          @detectors = {}
        end

        # Gets correspond symmetries detector
        # @param [Organizers::DependentWrappedSpec] spec for which detector will be
        #   gotten
        # @return [SymmetriesDetector] the correspond symmetries detector instance
        def get(spec)
          unless @detectors[spec]
            specie = @generator.specie_class(spec.name)
            raise 'Specie code generator is not found!' unless specie

            @detectors[spec] = SymmetriesDetector.new(@generator, specie)
            @detectors[spec].collect_symmetries
          end
          @detectors[spec]
        end
      end

    end
  end
end
