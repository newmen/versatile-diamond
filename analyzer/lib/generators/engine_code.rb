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
      end

      def generate(**params)
        props = classifier.props
        puts props.size

        result = classifier.general_transitive_matrix.to_a
        puts matrix_to_s(result)

        print 'Specification: '
        puts classifier.specification.join(', ')

        term_specs.map do |spec|
          print "#{spec.name} num: "

          values = Array.new(props.size) { 0 }
          classifier.classify(spec).each do |i, (_, n)|
            values[i] = n
          end
          puts values.join(', ')
        end

        puts "* -> H :: #{classifier.actives_to_deactives.join(', ')}"
        puts "H -> * :: #{classifier.deactives_to_actives.join(', ')}"
      end

    private

      def matrix_to_s(matrix)
        strs = matrix.map.with_index do |row, i|
          line = row.join(', ')
          "/* #{i.to_s.rjust(2)} */  #{line}"
        end
        strs.join(",\n")
      end

    end

  end
end
