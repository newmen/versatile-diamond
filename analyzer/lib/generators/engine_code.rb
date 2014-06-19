module VersatileDiamond
  module Generators

    # Generates program code based on engine framework for each interpreted entities
    class EngineCode < Base
      extend Forwardable

      def_delegator :classifier, :used_lattices

      # Initializes code generator
      # @param [Organizers::AnalysisResult] analysis_result see at super same argument
      # @param [String] out_path the path where result files will be placed
      def initialize(analysis_result, out_path)
        super(analysis_result)
        @out_path = out_path

        @species = collect_species
      end

      public :classifier, :ubiquitous_reactions, :spec_reactions, :term_specs,
        :specific_gas_species

      # Generates source code and configuration files
      def generate(**params)
        code_elements.each do |class_str|
          eval("Code::#{class_str}").new(self).generate(@out_path)
        end

        unique_pure_atoms.each { |atom| atom.generate(@out_path) }
        used_lattices.compact.each do |lattice|
          Code::Lattice.new(lattice, classifier).generate(@out_path)
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

      # Gets specie source files generator by some spec
      # @param [Organizers::DependentSpec] spec by which code generator will be got
      # @return [Code::Specie] the correspond code generator instance
      def specie_class(spec)
        binding.pry if !@species[spec.name]
        @species[spec.name]
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
      # @return [Hash] the mirror of dependent specs to spec code generator instances
      def collect_species
        mirror = (base_specs + specific_specs).each.with_object({}) do |spec, hash|
          hash[spec.name] = Code::Specie.new(self, spec)
        end

        config_specs.each.with_object(mirror) do |concept, hash|
          unless hash[concept.name]
            dep_spec = concept.simple? ?
              Organizers::DependentSimpleSpec.new(concept) :
              Organizers::DependentSpecificSpec.new(concept)

            hash[concept.name] = Code::Specie.new(self, dep_spec)
          end
        end
      end
    end

  end
end
