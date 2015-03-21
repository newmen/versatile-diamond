module VersatileDiamond
  using Patches::RichArray

  module Concepts

    # Instance of it class contain source and product specs. Also contained
    # all kinetic properties: enthalpy, activation energy and pre-exponential
    # factor as "raw" rate variable. Setuping it values provides trough
    # corresponding instance assertion methods.
    class UbiquitousReaction < Named
      include Modules::ListsComparer

      # Exception class for cases when property already setted
      class AlreadySet < Errors::Base
        attr_reader :property
        def initialize(property); @property = property end
      end

      class << self
      private
        # Defines some property getter and setter by adding assertion methods
        def define_property_acceptor(*properties)
          properties.each do |property|
            # Defines forward direction property getter
            # @return [Float] the value of property
            define_method(property) do
              instance_variable_get(:"@#{property}") || 0
            end

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

      define_property_acceptor :enthalpy, :activation, :rate, :temp_power
      attr_reader :source, :products

      # Store source and product specs
      # @param [Symbol] type the type of reaction, can be :forward or :reverse
      # @param [Array] source the array of source specs
      # @param [Array] products the array of product specs
      def initialize(type, name, source, products)
        super(name.to_s.gsub(/\(|\)|-/, ' ').to_sym)
        @type = type
        @source, @products = [source, products].map(&:dup)
        @simple_source, @simple_products = nil

        @reverse = nil

        @enthalpy, @activation, @rate = nil
      end

      # Gets a name of reaction with prepend type of reaction
      # @return [String] the name of reaction
      # @override
      def name
        "#{@type} #{super}"
      end

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
        @source.select(&:gas?).size
      end

      # Iterates each source spec
      # @yield [TerminationSpec] do for each reactant
      # @return [Enumerator] if block is not given
      def each_source(&block)
        @source.each(&block)
      end

      # Checks that passed spec is used in current reaction
      # @param [SpecificSpec] spec which will be checked
      # @return [Boolan] is used similar source spec or not
      def use_similar_source?(spec)
        @source.any? { |s| s == spec }
      end

      # Swaps source spec to another same source spec
      # @param [TerminationSpec | SpecificSpec] from which spec will be deleted
      # @param [TerminationSpec | SpecificSpec] to which spec will be added
      def swap_source(from, to)
        idx = @source.index(from)
        @source[idx] = to
      end

      # Compares two reactions and their source and products are same then
      # reactions same too
      #
      # @param [UbiquitousReaction] other reaction with which comparison
      # @return [Boolean] the result of comparing
      def same?(other)
        lists_are_identical?(@source, other.source, &:same?) &&
          lists_are_identical?(@products, other.products, &:same?)
      end

      # Calculate full rate of reaction
      # @return [Float] the full raction rate
      def full_rate
        rate == 0 ? 0 : Tools::Config.rate(self)
      end

      # Gets number of changed atoms
      # @return [Integer] 1
      def changes_num
        1
      end

      def to_s
        specs_to_s = -> specs { specs.map(&:name).join(' + ') }
        "#{specs_to_s[@source]} = #{specs_to_s[@products]}"
      end

      def inspect
        to_s
      end

    protected

      attr_writer :reverse

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
