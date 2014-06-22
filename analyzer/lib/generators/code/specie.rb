module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Creates Specie class
      class Specie < CppClassWithGen
        include PolynameClass

        # Initialize specie code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [Organizers::DependentSpec] spec source file for which will be
        #   generated
        def initialize(generator, spec)
          super(generator)
          @spec = spec
          @_class_name = nil
        end

        # Makes class name for current specie
        # @return [String] the result class name
        # @example generating name
        #   'bridge(ct: *, ct: i)' => 'BridgeCTsi'
        def class_name
          return @_class_name if @_class_name

          m = @spec.name.to_s.match(/(\w+)(\(.+?\))?/)
          addition =
            if m[2]
              params_str = m[2].scan(/\((.+?)\)/).first.first
              params = m[2].scan(/\w+: ./)
              spg = params.map { |p| p.match(/(\w+): (.)/) }
              groups = spg.group_by { |m| m[1] }
              strs = groups.map do |k, gs|
                states = gs.map { |item| item[2] == '*' ? 's' : item[2] }.join
                "#{k.upcase}#{states}"
              end
              strs.join
            end
          @_class_name = "#{m[1].classify}#{addition}"
        end
      end

    end
  end
end
