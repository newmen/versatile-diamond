module VersatileDiamond
  module Interpreter

    # Interprets reaction block and all of block parameters passes to concept,
    # instance of that will be created in equation method
    class Reaction < ComplexComponent
      include EquationProperties
      include SpecificSpecMatcher

      # Inits reaction interpter and store concept
      # @param [String] name the name of reaction concept which will be
      #   accumulate interpreted values
      def initialize(name)
        @name = name
      end

      # Stores aliases to internal hash for future checking and instancing
      # reactants
      #
      # @param [Hash] refs the hash which contain alias names as keys and
      #   original spec names as values
      def aliases(**refs)
        @aliases = refs
      end

      # Interpets equation line. Matches source and product specified specs
      # and store it to concept reaction. Where specs is matched then checks
      # complience matching and checks the balance of reaction. Also will be
      # checked composition of specs and if termination spec contained then
      # creates corresponding concept of reaction.
      #
      # @param [String] str the matching string with equation
      # @raise [Tools::Chest::KeyNameError] if any spec or atom is undefined
      # @raise [Errors::SyntaxError] if invalid string or wrong balance
      def equation(str)
        sides = Matcher.equation(str)
        syntax_error('.invalid') unless sides

        names_and_specs = {}
        source, products = [:source, :products].zip(sides).map do |type, specs|
          names_and_specs[type] = []
          specs.map do |spec_str|
            name_and_spec = detect_name_and_spec(spec_str)
            names_and_specs[type] << name_and_spec
            name_and_spec.last
          end
        end

        check_compliance(names_and_specs[:source], names_and_specs[:products])

        @concept = if has_termination_spec?(source, products)
            check_balance(source, products) || syntax_error('.wrong_balance')

            Concepts::UbiquitousReaction.new(@name, source, products)
            # doesn't nest equation if reaction is ubiquitous
          else
            check_balance(source, products) do |ext_src, ext_prd|
              # if source or products need (and can) to be extended then
              # exchange to extended specs
              source, products = ext_src, ext_prd
            end || syntax_error('.wrong_balance')

            atoms_map = AtomMapper.map(source, products)
            reaction = Concepts::Reaction.new(@name, source, products, atoms_map)
            nested(Equation.new(reaction, names_and_specs)) # TODO: rspec it condition
            reaction
          end

        Tools::Chest.store(@concept)
      rescue AtomMapper::EqualSpecsError => e
        syntax_error('.equal_specs', name: e.spec_name)
      rescue StructureMapper::CannotMap
        syntax_error('.cannot_map')
      end

    private

      # Detects the spec by passed spec_str and returns array with two elements
      # where the first element is name of spec and the second element is
      # corresponding spec
      #
      # @param [String] spec_str the matching string for detecting correspond
      #   spec
      # @raise [Errors::SyntaxError] if spec is atomic spec and atom for it has
      #   valence more than 1
      # @raise [Tools::Chest::KeyNameError] if atom or spec cannot be found
      # @return [Array] where first element is name of spec and second is spec
      def detect_name_and_spec(spec_str)
        if Matcher.active_bond(spec_str)
          ['*', Concepts::ActiveBond.new]
        elsif (atom_name = Matcher.atom(spec_str))
          atom = Tools::Chest.atom(atom_name)
          syntax_error('.invalid_valence') if atom.valence != 1
          [atom_name, Concepts::AtomicSpec.new(atom)]
        else
          using_name = nil
          spec = match_specific_spec(spec_str) do |name|
            using_name = name
            name = name.to_sym
            if @aliases && (original_name = @aliases[name])
              Tools::Chest.spec(original_name)
            else
              Tools::Chest.spec(name)
            end
          end
          [using_name, spec]
        end
      end

      # Checks containing termination spec in source or product specs
      # @param [Array] source the array of source specs
      # @param [Array] products the array of product specs
      # @return [Boolean] has or not
      def has_termination_spec?(source, products)
        check = -> specific_spec { specific_spec.is_a?(TerminationSpec) }
        source.find(&check) || products.find(&check)
      end

      # Checks compliance of source and product specs for both directions
      # @param [Array] source the array of source specs with it names in
      #   current reaction
      # @param [Array] products same as source argument
      # @raise [Errors::SyntaxError] if comlience is wrong
      def check_compliance(source, products, deep = 1)
        source.group_by { |name, _| name }.each do |_, group|
          product = products.find { |name, _| name == group.first.first }
          if group.size > 1 && product
            syntax_error('.cannot_be_mapped', name: group.first.first)
          end
        end

        check_compliance(products, source, deep - 1) if deep > 0
      end

      # Checks the balance of reaction. If balance is not valid then trying to
      # extend some source or product spec through atom-references. If need to
      # extend source spec and product spec at same time (and block is passed
      # too) then expansion is carried out by recursive calling of
      # #extends_if_possible method.
      #
      # @param [Array] source the array of source specs
      # @param [Array] products the array of product specs
      # @param [Integer] deep characterizes the depth of recursion
      # @yield pass to itself duplicates of extended and balanced specs
      # @return [Boolean] true if extending and balancing ok, or false overwise
      # TODO: if checks every possible extending way for complete condition
      #   then analyzer may accept incorrect equation
      def check_balance(source, products, deep = 2, &block)
        ebs = external_bonds_sum(source)
        ebp = external_bonds_sum(products)

        if ebs == ebp
          block[source, products] if block_given?
          true
        elsif block_given? && deep > 0
          if ebs < ebp
            extends_if_possible(:source, source, products, ebp, deep, &block)
          elsif ebs > ebp
            extends_if_possible(:products, source, products, ebs, deep, &block)
          end
        else
          false
        end
      end

      # Summarizes all external bonds of passed specs
      # @param [Array] specs the array of specs the bonds to which will be
      #   summarized
      # @return [Integer] the sum of external bonds
      def external_bonds_sum(specs)
        specs.map(&:external_bonds).reduce(:+)
      end

      # Trying to expand some spec of source or products. If need to extend
      # source spec and product spec at same time then expansion is carried out
      # by re-call this method through #check_balance method.
      #
      # @param [Symbol] type the name of array specs of which will be extended
      # @param [Array] source see at #check_balance same attribute
      # @param [Array] products see at #check_balance same attribute
      # @param [Integer] bonds_sum_limit the limit, which must be overcome to
      #   re-verify
      # @param [Integer] deep see at #check_balance same attribute
      # @yield see at #check_balance
      # @return [Boolean] see at #check_balance
      def extends_if_possible(type, source, products, bonds_sum_limit, deep, &block)
        specs = eval(type.to_s)
        combinations = specs.size.times.reduce([]) do |acc, i|
          acc + specs.combination(i + 1).to_a
        end

        combinations.each do |combination|
          bonds_sum = specs.reduce(0) do |acc, spec|
            acc + (combination.include?(spec) && spec.extendable? ?
              spec.external_bonds_after_extend :
              spec.external_bonds)
          end

          if bonds_sum >= bonds_sum_limit
            duplicate_specs = specs.map do |spec|
              spec.extend! if combination.include?(spec) && spec.extendable?
              spec
            end

            args = type == :source ?
              [duplicate_specs, products] :
              [source, duplicate_specs]

            result = check_balance(*args, deep - 1, &block)
            if result then return result else next end
          end
        end
        false
      end
    end

  end
end
