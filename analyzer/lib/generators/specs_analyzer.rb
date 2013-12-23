module VersatileDiamond
  module Generators

    # Provides methods for analyze species
    module SpecsAnalyzer
    private

      # Gets a atom properties classifier
      # @return [Tools::AtomClassifier] the instance of classifier
      def classifier
        @classifier ||= Tools::AtomClassifier.new
      end

      # Analyzes all used surface species by classifier
      def analyze_specs
        used_surface_specs.each { |spec| classifier.analyze(spec) }
        classifier.organize_properties!
      end

      # Gets all uniq used surface species
      # @return [Array] the array of used species
      def used_surface_specs
        return @used_surface_specs if @used_surface_specs
        @used_surface_specs = (base_specs + specific_specs).reject(&:is_gas?)
        cache =
          (base_specs.map(&:name) + specific_specs.map(&:full_name)).to_set
        nonubiquitous_reactions.each do |reaction|
          reaction.products.reject(&:is_gas?).each do |spec|
            name = spec.full_name
            next if cache.include?(name)
            cache << name
            @used_surface_specs << spec
          end
        end
        @used_surface_specs
      end

      # Gets all base surface species
      # @return [Array] the array of base specs
      def base_surface_specs
        base_specs.reject(&:is_gas?)
      end

      # Gets all specific surface species
      def specific_surface_specs
        used_surface_specs - base_surface_specs
      end
    end

  end
end
