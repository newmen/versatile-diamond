module VersatileDiamond
  module Interpreter

    # Interprets gas block
    class Gas < Phase

      # Setup concentration values in gase phase for specified spec
      # @param [String] specified_spec_str the string which describe matching
      #   specific spec
      # @param [Float] value the concentration of spec in gas phase
      # @param [String] dimension of concentration
      # @raise [Tools::Chest::KeyNameError] see as #detect_spec
      # @raise [Tools::Config::AlreadyDefined] if concentration of specified
      #   spec already defined
      # TODO: move this method to super class
      def concentration(specified_spec_str, value, dimension = nil)
        specific_spec = detect_spec(specified_spec_str)
        Tools::Config.gas_concentration(specific_spec, value, dimension)
      end

    private

      # Detects the specified spec by matching spec name and specifing atoms
      # @param [String] specific_spec_str the analyzing specific spec string
      # @raise [Tools::Chest::KeyNameError] if spec is undefined
      # @return [Concepts::SpecificSpec] instance of specific spec
      def detect_spec(specified_spec_str)
        name, args_str = Matcher.specified_spec(specified_spec_str)
        spec = Tools::Chest.gas_spec(name)

        specific_atoms = {}
        if args_str && args_str != ''
          extract_hash_args(args_str) do |key, value|
            atom = spec.atom(key)
            unless atom
              syntax_error('specific_spec.wrong_specification', atom: key)
            end

            specific_atom = specific_atoms[key] ||
              Concepts::SpecificAtom.new(atom)

            begin
              case value
              when 'i'
                specific_atom.incoherent!
              when 'u'
                specific_atom.unfixed!
              when /\A\*+\Z/
                value.scan('*').size.times do
                  specific_atom.active!
                end
              else syntax_error('specific_spec.wrong_specification', atom: key)
              end
            rescue Concepts::SpecificAtom::AlreadyStated
              syntax_error('specific_spec.atom_already_has_state',
                spec: name, atom: key, state: value)
            end

            specific_atoms[key] = specific_atom
          end
        end

        Concepts::SpecificSpec.new(spec, specific_atoms)
      rescue Concepts::Atom::IncorrectValence => e
        syntax_error('specific_spec.invalid_actives_num',
          spec: name, atom: e.atom)
      end

      def interpreter_class
        Interpreter::GasSpec
      end

      def concept_class
        Concepts::GasSpec
      end
    end

  end
end
