module VersatileDiamond
  module Generators

    # Generates program code based on engine framework for each interpreted entities
    class EngineCode < Base

      # Initializes code generator
      # @param [Organizers::AnalysisResult] analysis_result see at super same argument
      # @param [String] out_path the path where result files will be placed
      def initialize(analysis_result, out_path)
        super(analysis_result)
        @out_path = out_path

        @_dependent_species = nil
        @species = collect_code_species
        @lattices = collect_code_lattices
      end

      # provides methods from base generator class
      public :classifier, :ubiquitous_reactions, :spec_reactions, :term_specs

      # Generates source code and configuration files
      def generate(**params)
        species.each(&:find_self_symmetric!)

        [
          major_code_instances,
          unique_pure_atoms,
          lattices.compact,
          species
        ].each do |collection|
          collection.each { |code_class| code_class.generate(@out_path) }
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

      def specific_gas_species
        collect_dependent_species.values.select do |s|
          s.spec.gas? && (s.class == Organizers::DependentSimpleSpec ||
            s.class == Organizers::DependentSpecificSpec)
        end
      end

    private

      # Provides list of code elements the source code of which will generated
      # @return [Array] the array of names of code generator classes
      def code_elements
        %w(Handbook Env AtomBuilder)
      end

      # Gets the instances of major code elements
      # @return [Array] the array of instances
      def major_code_instances
        code_elements.map { |class_str| eval("Code::#{class_str}").new(self) }
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

      # Collects all used species from analysis results
      # @return [Hash] the mirror of specs names to dependent species
      def collect_dependent_species
        return @_dependent_species if @_dependent_species
        @_dependent_species = {}

        all_specs = (base_specs || []) + (specific_specs || [])
        all_specs.each { |spec| @_dependent_species[spec.name] = spec }
        config_specs.each.with_object(@_dependent_species) do |dep_spec, hash|
          hash[dep_spec.name] ||= dep_spec
        end
      end

      # Wraps all collected species from analysis results
      # @return [Hash] the mirror of specs names to spec code generator instances
      def collect_code_species
        collect_dependent_species.each.with_object({}) do |(name, spec), hash|
          hash[name] = Code::Specie.new(self, spec)
        end
      end

      # Collects all used lattices and wraps it by source code generator
      # @return [Hash] the mirror of lattices to code generator
      def collect_code_lattices
        hash = classifier.used_lattices.map do |concept|
          concept ? [concept, Code::Lattice.new(concept, classifier)] : [nil, nil]
        end
        Hash[hash]
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

      # Gets all collected species
      # @return [Array] the array of collected species
      def species
        deps_hash = collect_dependent_species
        surface_species = @species.reject do |name, _|
          dep_spec = deps_hash[name]
          dep_spec.simple? || (dep_spec.gas? && dep_spec.links.size == 1)
        end

        surface_species.values
      end
    end

  end
end
