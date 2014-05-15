module VersatileDiamond
  module Generators

    # Generates a table with overveiw information about concepts stored
    # in Chest
    class Overview < Base

      # Generates a table
      # @option [Boolean] :no_base_specs if set to true then base species doesn't shown
      # @option [Boolean] :no_spec_specs show or not specific species set
      # @option [Boolean] :no_reactions if set to true then reactions doesn't shown
      # @override
      def generate(no_base_specs: false, no_spec_specs: false, no_reactions: false)
        @atoms_format = '%25s | %5s | %10s | %4s | %s'
        puts @atoms_format % %w(Image Index Lattice Name Parents)
        print_atoms('Atoms', classifier.props)
        puts
        puts "Total number of different atom types: #{classifier.all_types_num}"
        puts "Total number of different atom types without relevant properties: #{classifier.notrelevant_types_num}"

        puts

        unless no_base_specs && no_spec_specs
          ml = column_size((base_specs + specific_specs).map(&:name).map(&:to_s))
          @specs_format = "%#{ml}s | %5s | %5s | %s"
          puts @specs_format % %w(Name Size ExtB Classification)
        end

        print_specs('Base specs', base_specs) unless no_base_specs
        print_specs('Specific specs', specific_specs) unless no_spec_specs

        unless no_base_specs && no_spec_specs
          puts
          puts "Total number of specs: #{base_specs.size + specific_specs.size}"
        end

        unless no_reactions
          2.times { puts } unless no_base_specs && no_spec_specs

          ml = column_size((ubiquitous_reactions + spec_reactions).map(&:formula))
          @reactions_format = "%#{ml}s | %5s | %2s | %1.3e | %s"
          puts @reactions_format.sub('1.3e', '9s') % %w(Formula Size Ch Rate Name)

          print_reactions('Ubiquitous reactions', ubiquitous_reactions)
          print_reactions('Typical reactions', typical_reactions)
          print_reactions('Lateral reactions', lateral_reactions)

          puts
          print "Total number of reactions: "
          puts ubiquitous_reactions.size + spec_reactions.size
        end
      end

    private

      # Calculates requided column length by max str length
      # @param [Array] strs the array of strings which are out in column
      # @return [Integer] the max string size plus one
      def column_size(strs)
        strs.max_by(&:size).size + 1
      end

      # Prints atoms list
      # @param [String] name the name which will be shown before list
      # @param [Array] atoms the atom properties which will be shown as table
      def print_atoms(name, atoms)
        return if atoms.empty?

        puts "\n#{name}:"
        atoms.sort_by(&:size).each do |atom|
          puts @atoms_format % [
            atom.to_s,
            classifier.index(atom),
            atom.lattice && atom.lattice.klass,
            atom.atom_name,
            atom.smallests && atom.smallests.map(&:to_s).join(', ')
          ]
        end
      end

      # Prints surface specs list
      # @param [String] name the name which will be shown before list
      # @param [Array] specs the species which will be shown as table
      def print_specs(name, specs)
        return if specs.empty?

        puts "\n#{name}: [#{specs.size}]"
        specs.sort_by(&:size).each do |spec|
          puts @specs_format % [
            spec.name,
            spec.spec.size.round(2),
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
            reaction.formula,
            reaction.size.round(2),
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
        hash.map { |k, v| '%3s : %7s %2d' % [k, *v] }.join(' | ')
      end
    end

  end
end
