module VersatileDiamond
  module Generators

    module Code; end

    class CodeGenerator < Base
      include SpecsAnalyzer

      def generate(**params)
        analyze_specs

        props = classifier.each_props.to_a
        puts props.size

        result = classifier.transitive_matrix.to_a
        puts matrix_to_s(result)

        term_matrix = termination_specs.map do |spec|
          puts spec.name

          values = Array.new(props.size) { 0 }
          classifier.classify(spec).each do |i, (_, n)|
            values[i] = n;
          end
          values
        end

        puts matrix_to_s(term_matrix)

        ubiquitous_reactions.each do |reaction|
          print "#{reaction.name}: "
          term_spec = (reaction.source - reaction.send(:simple_source)).first
          print "#{term_spec.name} -> "

          reaction.more_complex.each do |more_complex|
            spec_atom = more_complex.complex_source_spec_and_atom
            next unless term_spec.cover?(*spec_atom)

            print classifier.index(*spec_atom)
          end
          puts
        end

        puts "* -> H :: #{classifier.actives_to_deactives.join(', ')}"
        puts "H -> * :: #{classifier.deactives_to_actives.join(', ')}"
      end

    private

      def matrix_to_s(matrix)
        matrix.map { |row| row.join(', ') }.join(",\n")
      end

    end

  end
end
