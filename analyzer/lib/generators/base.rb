module VersatileDiamond
  module Generators

    # Provides useful methods for get collections of interpreted instances
    # @abstract
    class Base
      extend Forwardable

      # Initializes generator by analysis result
      # @param [Organizers::AnalysisResult] analysis_result the result of
      #   interpretation and analysis
      def initialize(analysis_result)
        @analysis_result = analysis_result
      end

    private

      def_delegators :@analysis_result, :base_specs, :specific_specs, :term_specs,
        :ubiquitous_reactions, :typical_reactions, :lateral_reactions

      # Collects all unique where objects
      # @return [Array] the array of where objects
      def wheres
        cache = {}
        @analysis_result.theres.each do |there|
          name = there.where.name
          cache[name] ||= there.where
        end
        cache.values
      end

      # Gets not ubiquitous reactions
      # @return [Array] the not ubiquitous reactions
      def spec_reactions
        @spec_reactions ||= @analysis_result.spec_reactions.flatten
      end

      # Creates atom classifier and analyse each surface spec
      def classifier
        return @classifier if @classifier

        @classifier = Organizers::AtomClassifier.new
        surface_specs.each { |spec| @classifier.analyze(spec) }
        @classifier.organize_properties!
        @classifier
      end

      # Collects all uniq used surface species
      def surface_specs
        @surface_specs ||= base_surface_specs + specific_surface_specs
      end

      # Gets all base surface species
      # @return [Array] the array of base specs
      def base_surface_specs
        base_specs.reject(&:gas?)
      end

      # Gets all specific surface species
      # @return [Array] the array of specific specs
      def specific_surface_specs
        specific_specs.reject(&:gas?)
      end
    end

  end
end
