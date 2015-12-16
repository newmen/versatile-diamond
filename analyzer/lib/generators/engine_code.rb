module VersatileDiamond
  using Patches::RichArray
  using Patches::RichString

  module Generators

    # Generates program code based on engine framework for each interpreted entities
    class EngineCode < Base

      MAIN_CODE_INST_NAMES = %w(atom_builder env finder handbook names).freeze

      attr_reader :sequences_cacher, :detectors_cacher

      # Initializes code generator
      # @param [Organizers::AnalysisResult] analysis_result see at super same argument
      # @param [String] out_path the path where result files will be placed
      def initialize(analysis_result, out_path)
        super(analysis_result)
        @out_path = out_path

        @sequences_cacher = Code::SequencesCacher.new
        @detectors_cacher = Code::DetectorsCacher.new(self)

        collect_code_lattices
        collect_code_species
        collect_code_reactions

        @_atom_builder, @_env, @_finder, @_handbook = nil
        @_dependent_species, @_root_species, @_surface_species, @_gas_species = nil
        @_all_classifications = nil
      end

      # provides methods from base generator class
      public :classifier, :base_surface_specs, :specific_surface_specs, :term_specs,
        :ubiquitous_reactions, :spec_reactions

      # Generates source code and configuration files
      def generate(**params)
        [
          major_code_instances,
          unique_pure_atoms,
          lattices.compact,
          surface_species,
          reactions
        ].each do |collection|
          collection.each { |code_class| code_class.generate(@out_path) }
        end
      end

      MAIN_CODE_INST_NAMES.each do |name|
        var_name = :"@_#{name}"
        # Gets #{name} class code generator
        # @return [#{name.classify}] the #{name} class code generator instance
        define_method(name.to_sym) do
          instance_variable_get(var_name) ||
            instance_variable_set(var_name, Code.const_get(name.classify).new(self))
        end
      end

      # Collects only unique base atom instances
      # @return [Array] the array of pure unique atom instances
      def unique_pure_atoms
        pure_atoms = base_specs.reduce([]) do |acc, spec|
          base_atoms = spec.links.keys.select do |atom|
            !atom.reference? && !atom.specific?
          end

          unificate(acc + base_atoms) { |a, b| a.name == b.name }
        end

        raise 'No unique atoms found!' if pure_atoms.empty?
        pure_atoms.map { |atom| Code::Atom.new(atom) }
      end

      # Gets all used lattices
      # @return [Array] the array of used lattices
      def lattices
        @lattices.values
      end

      # Gets lattice source classes code generator
      # @param [Concepts::Lattice] lattice by which code generator will be got
      # @return [Code::Lattice] the lattice code generator
      def lattice_class(lattice)
        @lattices[lattice]
      end

      # Gets specie source files generator by some specie name
      # @param [Symbol] spec_name by which code generator will be got
      # @return [Code::Specie] the correspond code generator instance
      def specie_class(spec_name)
        @species[spec_name]
      end

      # Gets the reaction code generator
      # @param [Symbol] reaction_name the name of reaction which will be returned
      # @return [Code::BaseReaction] the reaction code generator instance
      def reaction_class(reaction_name)
        @reactions[reaction_name]
      end

      # Gets root species
      # @return [Array] the array of root specie class code generators
      def root_species
        @_root_species ||= surface_species.select(&:find_root?)
      end

      # Gets non simple and non gas collected species
      # @return [Set] the array of collected specie class code generators
      def surface_species
        @_surface_species ||= surface_species_hash.values.to_set
      end

      # Gets the list of specific species which are gas molecules
      # @return [Array] the list of dependent specific gas species
      def specific_gas_species
        @_gas_species ||=
          dependent_species.values.select { |s| s.gas? && (s.simple? || s.specific?) }
      end

      # Checks that atom can contain several references to specie under simulation do
      # @param [Organizers::DependentWrappedSpec] spec the use of which will be checked
      #   for passed atom
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom which number possible references to correspond specie will be checked
      # @return [Boolean] is atom can be used in several species by the role which it
      #   plays in passed specie
      def many_times?(spec, atom)
        slice = all_classifications[spec.name]
        slice && slice[atom_properties(spec, atom)]
      end

      def inspect
        '✾'
      end

    private

      # Gets the instances of major code elements
      # @return [Array] the array of instances
      def major_code_instances
        MAIN_CODE_INST_NAMES.map { |name| send(name.to_sym) }
      end

      # Finds and drops not unique items which are compares by block
      # @param [Array] list of unificable elements
      # @yield [Object, Object] compares two elements
      # @return [Array] the array of unique elements
      def unificate(list, &block)
        ldp = list.dup
        result = []
        until ldp.empty?
          first = ldp.pop
          ldp.reject! { |item| block[first, item] }
          result << first
        end
        result
      end

      # Collects all used lattices and wraps it by source code generator
      # @return [Hash] the mirror of lattices to code generator
      def collect_code_lattices
        hash = classifier.used_lattices.map do |concept|
          concept ? [concept, Code::Lattice.new(self, concept)] : [nil, nil]
        end
        @lattices = Hash[hash]
      end

      # Collects all used species from analysis results
      # @return [Hash] the mirror of specs names to dependent species
      def dependent_species
        return @_dependent_species if @_dependent_species
        @_dependent_species = {}

        all_specs = (base_specs || []) + (specific_specs || [])
        all_specs.each { |spec| @_dependent_species[spec.name] = spec }
        @_dependent_species
      end

      # Wraps all collected species from analysis results. Makes the mirror of specie
      # names to specie code generator instances.
      def collect_code_species
        @species =
          dependent_species.each_with_object({}) do |(name, spec), acc|
            acc[name] = Code::Specie.new(self, spec)
          end

        @species.values.each(&:find_symmetries!)
      end

      # Wraps all analyzed reactions. Makes the mirror of reaction names to reaction
      # code generator instances.
      def collect_code_reactions
        local_reactions = spec_reactions.select(&:local?)
        lateral_reactions = spec_reactions.select(&:lateral?)
        typical_reactions = spec_reactions - local_reactions - lateral_reactions

        @reactions = {}
        if ubiquitous_reactions.empty?
          # if ubiquitous reactions are not presented then all local reactions
          # interpreted as typical reaction
          (local_reactions + typical_reactions).each do |reaction|
            wrap_reaction(Code::TypicalReaction, reaction)
          end
        else
          %w(ubiquitous local typical).each do |rtype|
            eval("#{rtype}_reactions").each do |reaction|
              wrap_reaction(Code.const_get("#{rtype.classify}Reaction"), reaction)
            end
          end
        end

        lateral_reactions.each do |reaction|
          wrap_reaction(Code::LateralReaction, reaction)
        end
      end

      # Wraps one reaction by passed code generator class and store it to interal
      # cache
      #
      # @param [Class] klass by which will be wrapped the passed reaction
      # @param [Organizers::DependentReaction] reaction which will be wrapped
      # @return [Code::Reaction] the wrapped reaction
      def wrap_reaction(klass, reaction)
        @reactions[reaction.name] = klass.new(self, reaction)
      end

      # Provides the hash of surface specie class generators with significant species
      # @return [Hash] the hash where keys are concept names of species and the values
      #   are specie class generators
      def surface_species_hash
        @species.reject do |name, _|
          spec = dependent_species[name]
          spec.simple? || spec.gas? || spec.termination? || !spec.deep_reactant?
        end
      end

      # Gets all reactions which were collected
      # @return [Array] the list of reaction code generators
      def reactions
        @reactions.values
      end

      # Provides general classification of anchors of all species
      # @return [Hash] the classification hash, where keys are specie names and values
      #   are hashes, which keys are anchors as atom properties and values are flag,
      #   that correspond atom can store several instances of specie by appropriate
      #   role in this specie
      # @example
      #   {
      #     :bridge => {
      #       (C%d<) => false,
      #       (^C%d<) => true
      #     },
      #     :methyl_on_bridge => {
      #       (_~C%d<) => false,
      #       (C~%d) => true
      #     }
      #   }
      def all_classifications
        @_all_classifications ||=
          dependent_species.values.reduce({}) do |acc, spec|
            acc[spec.name] = inject_to_classification(acc, spec) { |_, num| num > 1 }
            classificate_parents(acc, spec)
          end
      end

      # Extends passed classification hash for passed spec
      # @param [Hash] acc the general classification of all species
      # @param [Organizers::DependentWrappedSpec] spec which anchors will be classified
      # @yield [Integer] should return an unification flag value
      # @return [Hash] the extended classification hash with values for anchors of spec
      def inject_to_classification(acc, spec, &block)
        acc[spec.name] ||= {}
        classification = classifier.classify(spec)
        classification.each_with_object(acc[spec.name]) do |(_, (ap, num)), result|
          result[ap] ||= block[ap, num]
        end
      end

      # Extends passed classification hash by parents of passed spec
      # @param [Hash] acc the general classification of all species
      # @param [Organizers::DependentWrappedSpec] spec which parents will be classified
      # @return [Hash] the extended classification hash with true values for each
      #   anchor of parent species which are presented in passed spec several times
      def classificate_parents(acc, spec)
        spec.anchors.each_with_object(acc) do |anchor, result|
          same_pwts(spec, anchor).each do |parent, twin|
            twin_props = atom_properties(parent, twin)
            result[parent.name] =
              inject_to_classification(acc, parent) { |ap, _| ap == twin_props }
          end
        end
      end

      # Gets same parents with twins for passed spec and atom
      # @param [Organizers::DependentWrappedSpec] spec parents will be gotten
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   anchor for which twins also will be gotten
      # @return [Array] the list of unique parents with twins which several times uses
      #   by passed spec and atom
      def same_pwts(spec, anchor)
        anch_pwts = spec.parents_with_twins_for(anchor, anchored: true)
        groups = anch_pwts.groups { |args| pwt_group_key(*args) }
        groups.reject(&:one?).map(&:first)
      end

      # Gets key by which grouping for detect same parents with twins will do
      # @param [Organizers::DependentWrappedSpec] parent
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom] twin
      # @return [Array] the groupping key
      def pwt_group_key(parent, twin)
        [parent.original, twin, parent.atom_by(twin)]
      end
    end

  end
end
