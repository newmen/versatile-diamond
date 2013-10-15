module VersatileDiamond
  module Generators

    # module Code; end

    class CodeGenerator < Base
      include SpecsAnalyzer

      def generate(**params)
        analyze_specs

        puts classifier.each_props.to_a.size

        result = classifier.transitive_matrix.to_a
        result = result.map { |row| row.join(', ') }.join(",\n")
        puts result
      end
    end

  end
end
