module VersatileDiamond
  module Generators

    # Generates a table with overveiw information about surfaced species stored
    # in Chest
    class SpecsOverview < Base

      # Generates a table
      def generate
        @classifier = Tools::AtomClassifier.new
        @base_format = "%55s | %5s | %5s | %s"
        puts @base_format % %w(Name Size ExtB Classification)

        print_specs("Base specs", base_specs)
        print_specs("Specific specs", specific_specs, name_method: :full_name)

        puts
        puts "Total number of specs: #{base_specs.size + specific_specs.size}"
        puts "Total number of different atom types: #{@classifier.all_types_num}"
        puts "Total number of different atom types without relevant properties: #{@classifier.notrelevant_types_num}"
      end

    private

      # Prints surface specs list
      # @param [String] name the name which will be shown before list
      # @param [Array] specs the species which will be shown as table
      # @option [Symbol] :name_method the name of method which will be called
      #   for getting name of each printed spec
      def print_specs(name, specs, name_method: :name)
        specs = specs.reject(&:is_gas?)
        return if specs.empty?
        specs.each { |s| @classifier.analyze(s) }

        puts "\n#{name}: [#{specs.size}]"
        specs.reject(&:is_gas?).sort_by { |s| s.size }.each do |spec|
          puts @base_format % [
            spec.send(name_method),
            spec.size,
            spec.external_bonds,
            hash_str(@classifier.classify(spec))
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
