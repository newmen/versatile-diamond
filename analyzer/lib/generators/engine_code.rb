module VersatileDiamond
  using Patches::RichArray
  using Patches::RichString

  module Generators

    # Generates program code based on engine framework for each interpreted entities
    class EngineCode < Base

      MAIN_CODE_INST_NAMES =
        %w(atom_builder config env finder handbook names rates_reader).freeze

      attr_reader :sequences_cacher, :detectors_cacher

      # Initializes code generator
      # @param [Organizers::AnalysisResult] analysis_result see at super same argument
      # @param [String] out_path the path where result files will be placed
      # @param [Hash] opts
      def initialize(analysis_result, out_path, **opts)
        super(analysis_result, **opts)
        @out_path = out_path

        @sequences_cacher = Code::SequencesCacher.new
        @detectors_cacher = Code::DetectorsCacher.new(self)

        @lattices = collect_code_lattices
        @species = collect_code_species
        @reactions = collect_code_reactions

        reset_caches!
        surface_reactants.each(&:find_symmetries!)
      end

      # provides methods from base generator class
      public :classifier, :base_surface_specs, :specific_surface_specs, :term_specs,
        :ubiquitous_reactions, :spec_reactions

      # Generates source code and configuration files
      def generate(**)
        common_files = generating_instances.flat_map { |cc| cc.generate(@out_path) }
        (common_files.uniq + [common_main_file]).each { |f| f.copy_to(@out_path) }
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
          all_atoms = spec.links.keys
          base_atoms = all_atoms.reject { |atom| atom.reference? || atom.specific? }
          multivalents = base_atoms.select { |atom| atom.valence > 1 }
          unificate(acc + multivalents) { |a, b| a.name == b.name }
        end

        raise 'No unique atoms found!' if pure_atoms.empty?
        pure_atoms.map { |atom| Code::Atom.new(atom) }
      end

      # Gets all reactions which were collected
      # @return [Array] the list of reaction code generators
      def reactions
        @reactions.values
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
        @lattices[lattice.name]
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
        @_root_species ||= surface_reactants.select(&:find_root?)
      end

      # Gets non simple and non gas collected species
      # @return [Set] the array of collected specie class code generators
      def surface_reactants
        @_surface_reactants ||= surface_reactants_hash.values.to_set
      end

      # Gets the list of specific species which are gas molecules
      # @return [Array] the list of dependent specific gas species
      def specific_gas_specs
        @_gas_specs ||=
          dependent_specs.values.select { |s| s.gas? && (s.simple? || s.specific?) }
      end

      # Gets number of usages of passed atom in all major species
      # @param [Organizers::DependentWrappedSpec] spec which atom props will be checked
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom which number of usages will be counted
      # @option [Boolean] :latticed_too if is true then default latticed atoms also
      #   will be checked of several times usation for source species
      # @return [Integer] how many times passed atoms uses in all major species
      def usages_num(spec, atom, **kwargs)
        slice = all_classifications(**kwargs)[spec.name]
        (slice && slice[atom_properties(spec, atom)]) ||
          (spec.links.keys.include?(atom) ? 1 : 0)
      end

      # Checks that atom can contain several references to specie under simulation do
      # @param [Organizers::DependentWrappedSpec] spec the use of which will be checked
      #   for passed atom
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom which number possible references to correspond specie will be checked
      # @option [Boolean] :latticed_too if is true then default latticed atoms also
      #   will be checked of several times usation for source species
      # @return [Boolean] is atom can be used in several species by the role which it
      #   plays in passed specie
      def many_times?(spec, atom, **kwargs)
        usages_num(spec, atom, **kwargs) > 1
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

      # @return [CommonFile]
      def common_main_file
        CommonFile.new('main.cpp')
      end

      # @return [Array] the flatten list of all generating instances
      def generating_instances
        [
          major_code_instances,
          unique_pure_atoms,
          lattices.compact,
          surface_reactants,
          reactions
        ].flat_map(&:to_a) + [Makefile.new]
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
        classifier.used_lattices.each_with_object({}) do |concept, acc|
          if concept
            acc[concept.name] = Code::Lattice.new(self, concept)
          else
            acc[nil] = nil
          end
        end
      end

      # Gets the list of all available organized dependent species
      # @return [Array] the list with dependent species from analysis result
      def all_avail_specs
        (base_specs || []) + (specific_specs || [])
      end

      # Collects all used species from analysis results
      # @return [Hash] the mirror of specs names to dependent species
      def dependent_specs
        @_dependent_specs ||= Hash[all_avail_specs.map { |spec| [spec.name, spec] }]
      end

      # Wraps all collected species from analysis results. Makes the mirror of specie
      # names to specie code generator instances.
      def collect_code_species
        dependent_specs.each_with_object({}) do |(name, spec), acc|
          acc[name] = Code::Specie.new(self, spec)
        end
      end

      # Gets the list of reactions with code generator klass for each reactions list
      # @return [Array] list of pairs where first item is type of reaction and the
      #   second is list of reactions of it type
      def reactions_with_types
        local_reactions = spec_reactions.select(&:local?)
        lateral_reactions = spec_reactions.select(&:lateral?)
        typical_reactions = spec_reactions - local_reactions - lateral_reactions

        [[Code::LateralReaction, lateral_reactions]] +
          if ubiquitous_reactions.empty?
            # if ubiquitous reactions are not presented then all local reactions
            # interpreted as typical reaction
            [[Code::TypicalReaction, local_reactions + typical_reactions]]
          else
            %w(ubiquitous local typical).map do |rtype|
              [Code.const_get("#{rtype.classify}Reaction"), eval("#{rtype}_reactions")]
            end
          end
      end

      # Wraps all analyzed reactions
      # Makes the mirror of reaction names to reaction code generator instances
      # @return [Hash] the mirror of reactions names to dependent reactions
      def collect_code_reactions
        reactions_with_types.reduce({}) do |acc, args|
          acc.merge(wrap_reactions(*args))
        end
      end

      # Wraps one reaction by passed code generator class and store it to interal
      # cache
      #
      # @param [Class] klass by which the passed reaction will be wrapped
      # @param [Array] reactions which will be wrapped
      # @return [Hash] the mirror of reaction names to the wrapped instances
      def wrap_reactions(klass, reactions)
        Hash[reactions.map { |reaction| [reaction.name, klass.new(self, reaction)] }]
      end

      # Provides the hash of surface specie class generators with significant species
      # @return [Hash] the hash where keys are concept names of species and the values
      #   are specie class generators
      def surface_reactants_hash
        @species.select do |name, _|
          spec = dependent_specs[name]
          !skipping?(spec) && spec.deep_reactant?
        end
      end

      # Checks that passed spec is skipping
      # @param [Organizers::DependentWrappedSpec] spec which state will be checked
      # @return [Boolean] is interesed spec or not
      def skipping?(spec)
        spec.simple? || spec.gas? || spec.termination?
      end

      # Provides general classification of anchors of all species
      # @option [Boolean] :latticed_too if is true then default latticed atoms also
      #   will be checked of several times usation for source species
      # @return [Hash] the classification hash, where keys are specie names and values
      #   are hashes, which keys are anchors as atom properties and values are numbers,
      #   of usage these properties in all another major species
      # @example
      #   {
      #     :bridge => {
      #       (C%d<) => 1,
      #       (^C%d<) => 2
      #     },
      #     :methyl_on_bridge => {
      #       (_~C%d<) => 1,
      #       (C~%d) => 2 # if there is cross_bridge_on_bridges
      #     }
      #   }
      def all_classifications(latticed_too: true)
        @_all_classifications[latticed_too] ||=
          major_dept_specs.reduce({}) do |all, spec|
            acc = classificate_parents(all, spec)
            latticed_too ? inject_latticed_props(acc, spec) : acc
          end
      end

      # Gets a list of structured dependent species
      # @return [Array] the list of species which can be classified
      def major_dept_specs
        dependent_specs.values.reject(&method(:skipping?))
      end

      # Counts how many times latticed atom props contains the passed atom props
      # @param [Organizers::AtomProperties] latticed_props which will used as context
      # @param [Organizers::AtomProperties] props which will combined num times
      # @return [Integer] how many times making combination of atom properties can
      #   contains in latticed atom properties
      def contain_times(latticed_props, props)
        diff = latticed_props - props
        if diff
          num = 1
          if !diff.zero? && props.include?(diff)
            loop do
              sum = props + diff
              break unless sum && latticed_props.include?(sum)
              num += 1
              break if sum == latticed_props
            end
          end
          num
        else
          0
        end
      end

      # Counts number of usages pf passed atom props in each latticed atom props
      # @param [Organizers::AtomProperties] props which will combination will check
      # @return [Array] numbers of usages of making atom properties combination in
      #   latticed atom properties
      def latticed_contains_times(props)
        latticed_props = classifier.default_latticed_atoms
        undangled_props = latticed_props.select { |ap| ap.danglings.empty? }
        undangled_props.map { |def_ap| contain_times(def_ap, props) }
      end

      # Gets maximal number of usages pf passed atom props in latticed atom props
      # @param [Organizers::AtomProperties] props which will combination will check
      # @return [Integer] maximal number of usages of making atom properties
      #   combination in latticed atom properties
      def max_latticed_contains_times(props)
        @_max_latticed_contains_times[props] ||= latticed_contains_times(props).max
      end

      # Extend passed classification hash when atoms of passed spec like latticed atoms
      # @param [Hash] all the general classification of all species
      # @param [Organizers::DependentWrappedSpec] spec which anchors will be classified
      # @yield [Organizers::AtomProperties] counts a number of usages
      # @return [Hash] the extended classification hash with values for latticed atoms
      def inject_latticed_props(all, spec)
        inject_classification(all, spec, &method(:max_latticed_contains_times))
      end

      # Extends passed classification hash for passed spec
      # @param [Hash] all the general classification of all species
      # @param [Organizers::DependentWrappedSpec] spec which anchors will be classified
      # @yield [Organizers::AtomProperties] counts a number of usages
      # @return [Hash] the extended classification hash with values for anchors of spec
      def inject_classification(all, spec, &block)
        all[spec.name] ||= {}
        avail_props = spec.anchors.map { |atom| atom_properties(spec, atom) }
        avail_props.each_with_object(all.dup) do |ap, acc|
          inner = acc[spec.name]
          stored_value = inner[ap]
          usage_times = block[ap]
          inner[ap] = usage_times if !stored_value || usage_times > stored_value
        end
      end

      # Extends passed classification hash by parents of passed spec
      # @param [Hash] all the general classification of all species
      # @param [Organizers::DependentWrappedSpec] spec which parents will be classified
      # @return [Hash] the extended classification hash with usages number for each
      #   anchor of parent species which are presented in passed spec several times
      def classificate_parents(all, spec)
        ppns = same_pwts(spec).map { |pr, tw, n| [pr, atom_properties(pr, tw), n] }
        pr_with_ap_num = ppns.uniq { |pr, ap, n| [pr.original, ap, n] }
        triples = pr_with_ap_num + self_swapns(spec)
        triples.each_with_object(all) do |(parent, twin_props, num), acc|
          inject_classification(acc, parent) { |ap| twin_props == ap ? num : 1 }
        end
      end

      # Getsh list of triples just for passed specie
      # @param [Organizers::DependentWrappedSpec] spec which will be pseudo classified
      # @return [Array] the list of self triples for passed specie
      def self_swapns(spec)
        pss = spec.links.keys.map { |atom| atom_properties(spec, atom) }.uniq
        pss.map { |ap| [spec, ap, 1] }
      end

      # Gets same parents with twins for passed spec and atom
      # @param [Organizers::DependentWrappedSpec] spec which parents will be gotten
      # @return [Array] the list of unique parents with twins which several times uses
      #   by passed spec and atom
      def same_pwts(spec)
        groups = all_pps(spec).groups do |pr, (tw, a)|
          [pr.original, atom_properties(pr.original, tw), a]
        end

        groups.reject(&:one?).map do |group|
          pr, (tw, _) = group.first
          [pr, tw, group.map(&:first).uniq.size]
        end
      end

      # Gets the list of all possible structures where for each this structure the
      # parent, their twin and corresponding passed spec atom are present
      #
      # @param [Organizers::DependentWrappedSpec] spec which parents will be gotten
      # @return [Array] the list of specific pps structures
      def all_pps(spec)
        spec.links.keys.flat_map { |atom| pps_for(spec, atom) }
      end

      # Gets all possible parents with twin and correspond atom of spec for passed spec
      # and atom
      #
      # @param [Organizers::DependentWrappedSpec] spec which parents will be gotten
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom for which the twins also will be gotten
      # @return [Array] the list with all available parents with twin and correspond
      #   atom of spec
      def pps_for(spec, atom)
        pwts = spec.parents_with_twins_for(atom)
        pwts.map { |pr, tw| [pr, [tw, pr.atom_by(tw)]] } +
          pwts.flat_map do |pr, tw|
            pps_for(pr, tw).map do |sub_pr, (sub_tw, a)|
              [sub_pr, [sub_tw, pr.atom_by(a)]]
            end
          end
      end

      # Resets the internal caches
      def reset_caches!
        @_atom_builder, @_env, @_finder, @_handbook = nil
        @_dependent_specs, @_root_species, @_surface_reactants, @_gas_specs = nil
        @_all_classifications = {}
        @_max_latticed_contains_times = {}
      end
    end

  end
end
