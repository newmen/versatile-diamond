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
          @_class_name, @_enum_name = nil
        end

        [
          ['class', :classify, ''],
          ['enum', :upcase, '_']
        ].each do |name, method, separator|
          method_name = :"#{name}_name"
          var_name = :"@_#{method_name}"

          # Makes #{name} name for current specie
          # @return [String] the result #{name} name
          define_method(method_name) do
            var = instance_variable_get(var_name)
            return var if var

            m = @spec.name.to_s.match(/(\w+)(\(.+?\))?/)
            addition = "#{separator}#{name_suffix(m[2])}" if m[2]
            instance_variable_set(var_name, "#{m[1].send(method)}#{addition}")
          end
        end

        # Gets the result file name
        # @return [String] the result file name of atom class
        # @override
        def file_name
          enum_name.downcase
        end

        # Gets number of sceleton atoms used in specie and different from atoms of
        # parent specie
        #
        # @return [Integer] the number of atoms
        def atoms_num
          (@spec.rest || @spec).links.size
        end

      private

        # Makes suffix of name which is used in name builder methods
        # @param [String] brackets_str the string which contain brackets and some
        #   additional params of specie in them
        # @return [String] the suffix of name
        # @example generating name
        #   '(ct: *, ct: i, cr: i)' => 'CTsiCRi'
        def name_suffix(brackets_str)
          params_str = brackets_str.scan(/\((.+?)\)/).first.first
          params = brackets_str.scan(/\w+: ./)
          spg = params.map { |p| p.match(/(\w+): (.)/) }
          groups = spg.group_by { |m| m[1] }
          strs = groups.map do |k, gs|
            states = gs.map { |item| item[2] == '*' ? 's' : item[2] }.join
            "#{k.upcase}#{states}"
          end
          strs.join
        end
      end

    end
  end
end
