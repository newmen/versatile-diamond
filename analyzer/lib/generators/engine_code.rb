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

      public :classifier, :ubiquitous_reactions, :spec_reactions, :term_specs

      # Generates source code and configuration files
      def generate(**params)
        code_elements.each do |class_str|
          eval("Code::#{class_str}").new(self).generate(@out_path)
        end

        unique_pure_atoms.each { |atom_class| atom_class.generate(@out_path) }
        lattices.compact.each { |lattice_class| lattice_class.generate(@out_path) }
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

      # Gets specie source files generator by some spec
      # @param [Organizers::DependentSpec] spec by which code generator will be got
      # @return [Code::Specie] the correspond code generator instance
      def specie_class(spec)
        @species[spec.name]
      end

      def specific_gas_species
        collect_dependent_species.values.select do |s|
          s.spec.gas? &&
            (s.is_a?(Organizers::DependentSimpleSpec) ||
            s.is_a?(Organizers::DependentSpecificSpec))
        end
      end

    private

      # Provides list of code elements the source code of which will generated
      # @return [Array] the array of names of code generator classes
      def code_elements
        %w(Handbook Env AtomBuilder)
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
        config_specs.each do |concept|
          unless @_dependent_species[concept.name]
            dep_spec = concept.simple? ?
              Organizers::DependentSimpleSpec.new(concept) :
              Organizers::DependentSpecificSpec.new(concept)

            @_dependent_species[concept.name] = dep_spec
          end
        end
        @_dependent_species
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
      # @return [Array] the array of gas concept species
      def config_specs
        Tools::Config.concs.keys
      end
    end

  end
end
