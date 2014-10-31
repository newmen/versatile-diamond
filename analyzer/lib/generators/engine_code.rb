module VersatileDiamond
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
        @_dependent_species = nil
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
          species,
          reactions
        ].each do |collection|
          collection.each { |code_class| code_class.generate(@out_path) }
        end
      end

      MAIN_CODE_INST_NAMES.each do |name|
        # Gets #{name} class code generator
        # @return [#{name.classify}] the #{name} class code generator instance
        define_method(name.to_sym) do
          var_name = :"@_#{name}"
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

      # Gets root species
      # @return [Array] the array of root specie class code generators
      def root_species
        species.select(&:find_root?)
      end

      # Gets the list of specific species which are gas molecules
      # @return [Array] the list of dependent specific gas species
      def specific_gas_species
        collect_dependent_species.values.select do |s|
          s.gas? && (s.simple? || s.specific?)
        end
      end

      # Gets the reaction code generator
      # @param [Symbol] reaction_name the name of reaction which will be returned
      # @return [Code::Reaction] the reaction code generator instance
      def reaction_class(reaction_name)
        @reactions[reaction_name]
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
      def collect_dependent_species
        return @_dependent_species if @_dependent_species
        @_dependent_species = {}

        all_specs = (base_specs || []) + (specific_specs || [])
        all_specs.each { |spec| @_dependent_species[spec.name] = spec }
        config_specs.each_with_object(@_dependent_species) do |dep_spec, hash|
          hash[dep_spec.name] ||= dep_spec
        end
      end

      # Wraps all collected species from analysis results. Makes the mirror of specie
      # names to specie code generator instances.
      def collect_code_species
        @species = {}
        collect_dependent_species.each do |name, spec|
          @species[name] = Code::Specie.new(self, spec)
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

      # Gets the species from configuration tool
      # @return [Array] the array of gas species code generators
      def config_specs
        Tools::Config.concs.keys.map do |concept|
          concept.simple? ?
            Organizers::DependentSimpleSpec.new(concept) :
            Organizers::DependentSpecificSpec.new(concept)
        end
      end

      # Gets non simple and non gas collected species
      # @return [Array] the array of collected specie class code generators
      def species
        deps_hash = collect_dependent_species
        surface_species = @species.reject do |name, _|
          dep_spec = deps_hash[name]
          # TODO: is simple always gas?
          dep_spec.simple? || dep_spec.gas?
        end

        surface_species.values
      end

      # Gets all reactions which were collected
      # @return [Array] the list of reaction code generators
      def reactions
        @reactions.values
      end
    end

  end
end
