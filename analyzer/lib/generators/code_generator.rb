module VersatileDiamond
  module Generators

    module Code; end

    class CodeGenerator < Base
      include SpecsAnalyzer

      def generate(**params)
        analyze_specs

        props = classifier.each_props.to_a
        puts props.size

        result = classifier.general_transitive_matrix.to_a
        puts matrix_to_s(result)

        print "Specification: "
        puts classifier.specification.join(', ')

        termination_specs.map do |spec|
          print "#{spec.name} num: "

          values = Array.new(props.size) { 0 }
          classifier.classify(spec).each do |i, (_, n)|
            values[i] = n;
          end
          puts values.join(', ')
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
