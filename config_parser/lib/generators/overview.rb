module VersatileDiamond
  module Generators

    # Generates a table with overveiw information about concepts stored
    # in Chest
    class Overview < Base
      include SpecsAnalyzer

      # Generates a table
      # @option [Boolean] :no_specs if set to true then base species doesn't
      #   shown
      # @option [Boolean] :no_spec_specs if set to true then specific species
      #   doesn't shown
      # @option [Boolean] :no_reactions if set to true then reactions doesn't
      #   shown
      def generate(no_specs: false, no_spec_specs: false, no_reactions: false)
        analyze_specs

        if !no_specs || !no_spec_specs
          @specs_format = "%55s | %5s | %5s | %s"
          puts @specs_format % %w(Name Size ExtB Classification)
        end

        print_specs("Base specs", base_surface_specs) if !no_specs
        if !no_spec_specs
          print_specs("Specific specs", specific_surface_specs,
            name_method: :full_name)
        end

        if !no_specs || !no_spec_specs
          puts
          puts "Total number of specs: #{base_specs.size + specific_specs.size}"
          puts "Total number of different atom types: #{classifier.all_types_num}"
          puts "Total number of different atom types without relevant properties: #{classifier.notrelevant_types_num}"
        end

        if !no_reactions
          2.times { puts } if !no_specs || !no_spec_specs

          @reactions_format = "%100s | %5s | %2s | %1.3e | %s"
          puts @reactions_format.sub('1.3e', '9s') %
            %w(Formula Size Ch Rate Name)

          print_reactions("Ubiquitous reactions", ubiquitous_reactions)
          print_reactions("Typical reactions", typical_reactions)
          print_reactions("Lateral reactions", lateral_reactions)

          puts
          puts "Total number of reactions: #{ubiquitous_reactions.size + nonubiquitous_reactions.size}"
        end
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
          puts @specs_format % [
            spec.send(name_method),
            spec.size,
            spec.external_bonds,
            hash_str(classifier.classify(spec))
          ]
        end
      end

      # Prints reactions list
      # @param [String] name the name wich will be shown before list
      # @param [Array] reactions the reactions which will be printed
      def print_reactions(name, reactions)
        return if reactions.empty?
        reactions = reactions.sort do |a, b|
          a.size == b.size ? b.full_rate <=> a.full_rate : a.size <=> b.size
        end

        puts "\n#{name}: [#{reactions.size}]"
        reactions.each do |reaction|
          puts @reactions_format % [
            reaction.to_s,
            reaction.size,
            reaction.changes_size,
            reaction.full_rate,
            reaction.name,
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
