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

    private

      def_delegators :@analysis_result, :base_specs, :specific_specs, :term_specs,
        :ubiquitous_reactions, :typical_reactions, :lateral_reactions

      ANALYS_SPEC_METHODS = %i(base_spec specific_spec).freeze

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

      # Checks that classfication of available atom properties done
      # @return [Boolean] is classified and organized atom properties
      def classified?
        !!@_classifier
      end

      # Creates atom classifier and analyse each surface spec
      # @return [Organizers::AtomClassifier]
      def classifier
        return @_classifier if classified?

        raw_clf = Organizers::AtomClassifier.new(!ubiquitous_reactions.empty?)
        surface_specs.each { |spec| raw_clf.analyze!(spec) }
        raw_clf.organize_properties!

        loop do
          there_is_new = false
          typical_reactions.each do |reaction|
            reaction.changes.each do |src_to_prd|
              unless src_to_prd.map(&:first).any?(&:gas?)
                raw_props = atom_properties_list(src_to_prd)
                there_is_new ||= raw_clf.reorganize_with!(raw_props)
              end
            end
          end
          break unless there_is_new
        end

        @_classifier = raw_clf
      end

      # Makes atom properties from passed list of specs and atoms
      # @param [Array] specs_atoms which will transformed to atom properties
      # @return [Array] the list of corresponding atom properties
      def atom_properties_list(specs_atoms)
        specs_atoms.map do |spec, atom|
          proxy_spec = dept_spec(spec).clone_with_replace(spec)
          atom_properties(proxy_spec, atom)
        end
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

        result || @analysis_result.base_spec(spec.spec.name) ||
          if spec.class == Concepts::SpecificSpec
            dept_spec_spec = Organizers::DependentSpecificSpec.new(spec)
            dept_spec_spec.specific? ? dept_spec_spec : make_dept_base_spec(spec.spec)
          else
            make_dept_base_spec(spec)
          end
      end

      # Wraps passed concept spec and creates new dependent base spec
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] spec
      #   the concept for which dependent base spec will be gotten
      # @return [Organizers::DependentBaseSpec] new combined dependent base spec
      def make_dept_base_spec(spec)
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
