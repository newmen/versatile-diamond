module VersatileDiamond
  module Concepts

    # Instance of it class contain source and product specs. Also contained
    # all kinetic properties: enthalpy, activation energy and pre-exponential
    # factor as "raw" rate variable. Setuping it values provides trough
    # corresponding instance assertion methods.
    class UbiquitousReaction < Named
      include Modules::ListsComparer
      include Visitors::Visitable

      # Exception class for cases when property already setted
      class AlreadySet < Exception
        attr_reader :property
        def initialize(property); @property = property end
      end

      class << self
      private
        # Defines some property getter and setter by adding assertion methods
        def define_property_setter(*properties)
          properties.each do |property|
            attr_reader property

            # Defines forward direction property setter
            # @raise [UbiquitousReaction::AlreadySet] if property already set
            # @param [Float] value the value of property
            define_method("#{property}=") do |value|
              if instance_variable_get(:"@#{property}")
                raise UbiquitousReaction::AlreadySet.new(property)
              end
              update_attribute(property, value)
            end
          end
        end
      end

      define_property_setter :enthalpy, :activation, :rate
      attr_reader :source, :products

      # Store source and product specs
      # @param [Symbol] type the type of reaction, can be :forward or :reverse
      # @param [Array] source the array of source specs
      # @param [Array] products the array of product specs
      def initialize(type, name, source, products)
        super(name)
        @type = type
        @source, @products = source, products

        @source.sort! { |a, b| b.size <=> a.size }
      end

      # Gets a name of reaction with prepend type of reaction
      # @return [String] the name of reaction
      # @override
      def name
        "#{@type} #{super}"
      end

      # Makes reversed reaction instance and change current name by append
      # "forward" word
      #
      # @return [UbiquitousReaction] reversed reaction
      def reverse
        return @reverse if @reverse
        @reverse = self.class.new(*reverse_params)
        @reverse.reverse = self
        @reverse
      end

      # Counts gases num in source specs scope
      # @return [Integer] number of specs that belongs to gas phase
      def gases_num
        @source.select(&:is_gas?).size
      end

      # Iterates each source spec
      # @yield [TerminationSpec] do for each reactant
      # @return [Enumerator] if block is not given
      def each_source(&block)
        source = @source.dup
        block_given? ? source.each(&block) : source.each
      end

      # Swaps source spec to another same source spec
      # @param [TerminationSpec | SpecificSpec] from which spec will be deleted
      # @param [TerminationSpec | SpecificSpec] to which spec will be added
      def swap_source(from, to)
        @source.delete(from)
        @source << to
      end

      # Compares two reactions and their source and products are same then
      # reactions same too
      #
      # @param [UbiquitousReaction] other reaction with which comparison
      # @return [Boolean] the result of comparing
      def same?(other)
        spec_compare = -> spec1, spec2 { spec1.same?(spec2) }
        lists_are_identical?(@source, other.source, &spec_compare) &&
          lists_are_identical?(@products, other.products, &spec_compare)
      end

      # Gets more complex reactions received after organization of dependencies
      # @return [Array] the array of more complex reactions
      def more_complex
        @more_complex ||= []
      end

      # Organize dependencies from another not ubiquitous reactions
      # @param [Array] not_ubiquitous_reactions the possible children
      def organize_dependencies!(not_ubiquitous_reactions)
        # number of termination specs should == 1
        term_spec = (@source - simple_source).first

        condition = -> spec1, spec2 { spec1.same?(spec2) }

        not_ubiquitous_reactions.each do |possible_child|
          simples_are_identical = lists_are_identical?(
            simple_source, possible_child.simple_source, &condition) &&
              lists_are_identical?(
                simple_products, possible_child.simple_products, &condition)

          next unless simples_are_identical &&
            possible_child.complex_source_covered_by?(term_spec)

          more_complex << possible_child
        end
      end

      # Calculate full rate of reaction
      # @return [Float] the full raction rate
      def full_rate
        return 0 unless @rate && @activation
        Tools::Config.rate(self)
      end

      # Counts size of all source specs
      # @return [Integer] number of surface atoms used in reaction
      def size
        @source.map(&:size).reduce(:+)
      end

      # Gets number of changed atoms
      # @return [Integer] 1
      def changes_size
        1
      end
      # Also visit target source spec
      # @param [Visitors::Visitor] visitor the object that will accumulate
      #   state of current instance
      # @override
      def visit(visitor)
        super
        @source.each { |spec| spec.visit(visitor) }
      end

      def to_s
        specs_to_s = -> specs { specs.map(&:full_name).join(' + ') }
        "#{specs_to_s[@source]} = #{specs_to_s[@products]}"
      end

      def inspect
        to_s
      end

    protected

      attr_writer :reverse

      %w(source products).each do |target|
        # Selects and caches simple specs from #{target} array
        # @return [Array] cached array of simple #{target} specs
        name = "simple_#{target}"
        define_method(name) do
          var = instance_variable_get(:"@#{name}")
          return var if var

          specs = instance_variable_get(:"@#{target}").
            select { |specific_spec| specific_spec.simple? }
          instance_variable_set(:"@#{name}", specs)
        end
      end

    private

      # Updates reaction property
      # @param [Symbol] attribute the name of instance variable
      # @param [Float] value the variable value
      def update_attribute(attribute, value)
        instance_variable_set(:"@#{attribute}", value)
      end

      # Makes params for reverse method
      def reverse_params
        type = @type != :forward ? :forward : :reverse
        [type, @name, @products, @source]
      end
    end

  end
end
