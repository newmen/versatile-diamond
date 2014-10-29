module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Generates major configuration file as c++ source code
      class Handbook < CppClassWithGen
        extend Forwardable

      private

        def_delegators :generator, :classifier, :lattices, :spec_reactions

        # Checks that ubiquitous reactions presented in original set
        # @return [Boolean] exists or not
        def ubiquitous_reactions_exists?
          return true if !generator.ubiquitous_reactions.empty?

          if spec_reactions.any?(&:local?)
            raise 'Local reactions could not be without ubiquitous reactions'
          end
          false
        end

        # Checks that lateral reactions presented in original set
        # @return [Boolean] exists or not
        def lateral_exists?
          spec_reactions.any?(&:lateral?)
        end

        # Check that results contain amorph phase
        # @return [Boolean] contain or not
        def amorph_exists?
          lattices.include?(nil)
        end

        # Gets all usable phases of atoms (lattices and amorphous if need)
        # @param [Array] the array of string names of generated dependent entities
        def phases
          lattices.map do |lattice|
            lattice ? lattice.class.to_s.underscore : 'phase_bondary'
          end
        end

        # Gets the list of used crystal lattices
        # @return [Array] the list of crystal lattices
        def crystal_lattices
          lattices.reject(&:nil?)
        end

        # Gets the atoms quantity
        # @return [Integer] the number of atoms
        def atoms_num
          classifier.props.size
        end

        # Gets the number of regular atoms
        # @return [Integer] the number of regular atoms
        def regular_atoms_num
          crystal_lattices.size
        end

        # Gets the list of regular atoms types
        # @return [String] the string in which enumerated types of regular atoms
        def regular_atoms_types
          crystal_lattices.map(&:major_atom_index).join(', ')
        end

        # Gets the transitive closured matrix of atom types
        # @return [String] the string rows of matrix
        def atoms_matrix
          matrix = classifier.general_transitive_matrix.to_a
          matrix_to_s(matrix)
        end

        # Gets the specifications of each atoms
        # @return [String] the result of atom properties specification
        def atoms_specification
          classifier.specification.join(', ')
        end

        # Delegates the methods to classifier
        # TODO: if not hydrogen used in system then not be generated methods with
        #   hydrogen in source
        %w(actives_to_deactives deactives_to_actives).each do |name|
          define_method(name) { classifier.public_send(name).join(', ') }
        end

        # Gets the mirror of each termination spec to their numbers on atoms
        # @return [Hash] the hash of numbers of terminations on each atom
        def nums_on_terms
          generator.term_specs.each_with_object({}) do |term_spec, hash|
            hash[term_spec.name] = term_nums(term_spec)
          end
        end

        # Makes string from matrix
        # @param [Array] matrix the original matrix
        # @return [String] matrix as multiline string
        def matrix_to_s(matrix)
          width = classifier.props_hash.keys.max.to_s.size
          str = matrix.map.with_index do |row, i|
            line = row.join(', ')
            "/* #{i.to_s.rjust(width)} */  #{line}"
          end
          str.join(",\n")
        end

        # Calculates number of terminated species on each atom
        # @param [DependentTermination] term_spec the termination spec for which
        #   numbers will gotten
        # @param [String] the array of numbers as string
        def term_nums(term_spec)
          values = Array.new(atoms_num) { 0 }
          classifier.classify(term_spec).each do |i, (_, n)|
            values[i] = n
          end
          values.join(', ')
        end
      end

    end
  end
end
