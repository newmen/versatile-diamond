module VersatileDiamond
  module Generators

    # Generates a table with overveiw information about surfaced species stored
    # in Chest
    class SpecsOverview < Base
      include SpecsAnalyzer

      # Generates a table
      def generate
        analyze_specs

        @base_format = "%55s | %5s | %5s | %s"
        puts @base_format % %w(Name Size ExtB Classification)

        print_specs("Base specs", base_surface_specs)
        print_specs("Specific specs", specific_surface_specs,
          name_method: :full_name)

        puts
        puts "Total number of specs: #{base_specs.size + specific_specs.size}"
        puts "Total number of different atom types: #{classifier.all_types_num}"
        puts "Total number of different atom types without relevant properties: #{classifier.notrelevant_types_num}"

        puts
        puts "Total number of reactions: #{ubiquitous_reactions.size + nonubiquitous_reactions.size}"
        puts "  where ubiquitous reactions: #{ubiquitous_reactions.size}"
        puts "  where typical reactions: #{typical_reactions.size}"
        puts "  where lateral reactions: #{lateral_reactions.size}"
      end

    private

      # Prints surface specs list
      # @param [String] name the name which will be shown before list
      # @param [Array] specs the species which will be shown as table
      # @option [Symbol] :name_method the name of method which will be called
      #   for getting name of each printed spec
      def print_specs(name, specs, name_method: :name)
        return if specs.empty?

        puts "\n#{name}: [#{specs.size}]"
        specs.sort_by(&:size).each do |spec|
          puts @base_format % [
            spec.send(name_method),
            spec.size,
            spec.external_bonds,
            hash_str(classifier.classify(spec))
          ]
        end
      end

      # Makes a beauty string from hash
      # @param [Hash] hash the hash which will be casted to string
      # @return [String] cast result
      def hash_str(hash)
        hash.map { |k, v| "%3s : %7s %2d" % [k, *v] }.join(' | ')
      end
    end

  end
end
