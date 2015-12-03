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
        @_spec_reactions, @_classifier, @_surface_specs = nil
      end

    private

      def_delegators :@analysis_result, :base_specs, :specific_specs, :term_specs,
        :ubiquitous_reactions, :typical_reactions, :lateral_reactions

      ANALYS_SPEC_METHODS = %i(base_spec specific_spec)

      # Collects all chunks
      # @return [Array] the array of chunks
      def chunks
        lateral_reactions.map(&:chunk)
      end

      # Gets not ubiquitous reactions
      # @return [Array] the not ubiquitous reactions
      def spec_reactions
        @_spec_reactions ||= [typical_reactions, lateral_reactions].flatten
      end

      # Creates atom classifier and analyse each surface spec
      def classifier
        return @_classifier if @_classifier

        analyzed_specs = Set.new
        specs_with_ions = []
        typical_reactions.each do |reaction|
          reaction.surface_specs.each do |spec|
            next if analyzed_specs.include?(spec)
            analyzed_specs << spec
            specs_with_ions[spec.name] ||= []
            specs_with_ions[spec.name] << exchange_ions?(spec)
          end
        end

        is_ions_presented =
          !ubiquitous_reactions.empty? || specs_with_ions.values.flatten.any?

        @_classifier = Organizers::AtomClassifier.new(is_ions_presented)
        surface_specs.each do |spec|
          @_classifier.analyze(spec, with_ions: specs_with_ions[spec].any?)
        end

        @_classifier.organize_properties!
        @_classifier
      end

      # Is there the exchange of some ions on specie in reaction?
      # @param [Organizers::DependentSpecReaction] reaction where the interactions
      #   will be checked
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
      #   which ions changes will be checked
      # @return [Boolean] is there exchanges or not?
      def exchange_ions?(reaction, spec)
        reaction.each_source.any?(&:simple?) ||
          reaction.changes.any? do |src_to_prd|
            s, a = src_to_prd.first
            next unless spec == s
            diff = :-.to_proc[*atom_properties_list(src_to_prd)]
            just_activated_props(a).any? { |props| props == diff }
          end
      end

      # Makes possible raw atom properties from passed atom
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom] atom
      #   for which the raw properties will be constructed
      # @return [Array] the list of raw properties
      def just_activated_props(atom)
        atom.valence.times.map do |i|
          danglings = [Concepts::ActiveBond.property] * (i + 1)
          Organizers::AtomProperties.raw(atom, danglings: danglings)
        end
      end

      # Makes atom properties from passed list of specs and atoms
      # @param [Array] specs_atoms which will transformed to atom properties
      # @return [Array] the list of corresponding atom properties
      def atom_properties_list(specs_atoms)
        specs_atoms.map do |spec, atom|
          Organizers::AtomProperties.new(dept_spec(spec), atom)
        end
      end

      # Gets dependent spec from concept spec
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
      #   the concept for which dependent spec will be gotten
      # @return [Organizers::DependentWrappedSpec] the corresponding specie which was
      #   combined under analysis of interpretation results
      def dept_spec(spec)
        ANALYS_SPEC_METHODS.reduce(nil) do |acc, method_name|
          acc || @analysis_result.public_send(method_name, spec.name)
        end
      end

      # Collects all uniq used surface species
      def surface_specs
        @_surface_specs ||= base_surface_specs + specific_surface_specs
      end

      # Gets all base surface species
      # @return [Array] the array of base specs
      def base_surface_specs
        (base_specs || []).reject(&:gas?)
      end

      # Gets all specific surface species
      # @return [Array] the array of specific specs
      def specific_surface_specs
        (specific_specs || []).reject(&:gas?)
      end
    end

  end
end
