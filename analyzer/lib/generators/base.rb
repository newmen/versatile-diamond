module VersatileDiamond
  module Generators

    # Provides useful methods for get collections of interpreted instances
    # @abstract
    class Base
      extend Forwardable

      # Initializes generator by analysis result
      # @param [Organizers::AnalysisResult] analysis_result the result of
      #   interpretation and analysis
      # @option [String] :config_path if passed then the cached data will be checked
      def initialize(analysis_result, config_path: nil)
        @analysis_result = analysis_result
        @config_path = config_path

        @_spec_reactions, @_classifier, @_surface_specs, @_changes = nil
      end

      # Gets atom properties for passed entities
      # @overload atom_properties(dept_spec, atom)
      #   @param [Organizers::DependentWrappedSpec | Oragnizers::ProxyParentSpec]
      #     dept_spec in which context the atom properties will be built
      #   @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #     atom by which the properties will be gotten
      # @overload atom_properties(props)
      #   @param [Organizers::AtomProperties] props which classified analog will be
      #     returned
      # @return [Organizers::AtomProperties] the classified atom properties
      def atom_properties(*args)
        props = args.one? ? args.first : Organizers::AtomProperties.new(*args)
        (classified? && classifier.props.find { |x| x == props }) || props
      end

      # Tries to load state from cache file
      # @param [String] suffix of loading file
      def load(suffix)
        @config_path && Tools::Serializer.load(@config_path, suffix: suffix)
      end

      # Saves state to cache file
      # @param [String] suffix of saving file
      # @param [Object] data which will be cached to file
      # @return [Object] the saving data
      def save(suffix, data)
        if @config_path
          Tools::Serializer.save(@config_path, data, suffix: suffix)
        else
          data
        end
      end

    private

      def_delegators :@analysis_result, :base_specs, :specific_specs, :term_specs,
        :ubiquitous_reactions, :typical_reactions, :lateral_reactions

      CLASSIFIER_CACHE_SUFFIX = 'classifier'.freeze
      ANALYS_SPEC_METHODS = %i(base_spec specific_spec).freeze

      # Collects all chunks
      # @return [Array] the array of chunks
      def chunks
        lateral_reactions.map(&:chunk)
      end

      # Gets not ubiquitous reactions
      # @return [Array] the not ubiquitous reactions
      def spec_reactions
        @_spec_reactions ||= typical_reactions + lateral_reactions
      end

      # Checks that classfication of available atom properties done
      # @return [Boolean] is classified and organized atom properties
      def classified?
        !!@_classifier
      end

      # Creates atom classifier and analyse each surface spec
      # @return [Organizers::AtomClassifier]
      def classifier
        @_classifier ||= !classified? && load(CLASSIFIER_CACHE_SUFFIX)
        return @_classifier if @_classifier

        raw_clf = Organizers::AtomClassifier.new(using_atomic_specs)
        surface_specs.each { |spec| raw_clf.analyze!(spec) }
        raw_clf.organize_properties!

        @_classifier = save(CLASSIFIER_CACHE_SUFFIX, raw_clf)
      end

      # Gets the list of using atomic species
      # @return [Array]
      def using_atomic_specs
        specs = ubiquitous_reactions.flat_map do |reaction|
          source = reaction.source.reject(&:gas?)
          source.all?(&:termination?) ? source.select(&:termination?) : []
        end
        specs.uniq
      end

      # Gets dependent spec from concept spec
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
      #   the concept for which dependent spec will be gotten
      # @return [Organizers::DependentWrappedSpec] the corresponding specie which was
      #   combined under analysis of interpretation results
      def dept_spec(spec)
        result = ANALYS_SPEC_METHODS.reduce(nil) do |acc, method_name|
          acc || @analysis_result.public_send(method_name, spec.name)
        end

        result ||
          if spec.specific?
            dept_spec_spec = Organizers::DependentSpecificSpec.new(spec)
            dept_spec_spec.specific? ? dept_spec_spec : dept_base_spec(spec.spec)
          else
            dept_base_spec(spec)
          end
      end

      # Wraps passed concept spec and creates new dependent base spec
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
      #   the concept for which dependent base spec will be gotten
      # @return [Organizers::DependentBaseSpec] new combined dependent base spec
      def dept_base_spec(spec)
        @analysis_result.base_spec(spec.name) ||
          Organizers::DependentBaseSpec.new(spec)
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
