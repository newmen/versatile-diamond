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
        attr_reader :reaction, :property, :value
        def initialize(reaction, property, value)
          @reaction = reaction
          @property = property
          @value = value
        end
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
              old_value = instance_variable_get(:"@#{property}")
              if old_value
                raise UbiquitousReaction::AlreadySet.new(self, property, old_value)
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
        super(name.to_s.gsub(/\(|\)|-/, ' ').gsub('  ', ' ').to_sym)
        @type = type
        @source, @products = [source, products].map(&:dup)
        @simple_source, @simple_products = nil

        @reverse = nil

        @enthalpy, @activation, @rate = nil
      end

      # Checks that reverse reaction was created
      # @return [Boolean] is created reverse reaction or not
      def has_reverse?
        !!@reverse
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
        name = :"simple_#{target}"
        define_method(name) do
          var = instance_variable_get(:"@#{name}")
          return var if var

          specs = instance_variable_get(:"@#{target}").select(&:simple?)
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

      # Iterates each target spec
      # @param [Symbol] target the type of swapping species
      # @yield [TerminationSpec] do for each reactant
      # @return [Enumerator] if block is not given
      def each(target, &block)
        instance_variable_get(:"@#{target}").each(&block)
      end

      # Checks that passed spec is used in current reaction
      # @param [Symbol] target the type of swapping species
      # @param [SpecificSpec] spec which will be checked
      # @return [Boolan] is used similar source spec or not
      def use_similar?(target, spec)
        instance_variable_get(:"@#{target}").any? { |s| s == spec }
      end

      # Swaps source spec to another same source spec
      # @param [Symbol] target the type of swapping species
      # @param [TerminationSpec | SpecificSpec] from which spec will be deleted
      # @param [TerminationSpec | SpecificSpec] to which spec will be added
      def swap_on(target, from, to, reverse_too: true)
        var = instance_variable_get(:"@#{target}")
        idx = var.index(from)
        var[idx] = to if idx

        if reverse_too && has_reverse?
          reverse_target = (target == :source) ? :products : :source
          reverse.swap_on(reverse_target, from, to, reverse_too: false)
        end
      end

      # Compares two reactions and their source and products are same then
      # reactions same too
      #
      # @param [UbiquitousReaction] other reaction with which comparison
      # @return [Boolean] the result of comparing
      def same?(other)
        self.class == other.class && same_specs?(other)
      end

      # Checks that current and other reactions have same source and product specs
      # @param [UbiquitousReaction] other comparing reaction
      # @return [Boolean] are same specs or not
      def same_specs?(other)
        lists_are_identical?(source, other.source, &:same?) &&
          lists_are_identical?(products, other.products, &:same?)
      end

      # Gets list of reaction rate properties
      # @return [Hash]
      def rate_tuple
        return {
          activation: activation,
          rate: rate,
          temp_power: temp_power,
        }
      end

      # Calculate full rate of reaction
      # @return [Float] the full raction rate
      def full_rate
        @rate ? Tools::Config.rate(self) : 0
      end

      # Checks that current reaction has not zero rate
      # @return [Boolean] is significant or not
      def significant?
        full_rate > 0
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
