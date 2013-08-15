module VersatileDiamond
  module Concepts

    # Instance of it class contain source and product specs. Also contained
    # all kinetic properties: enthalpy, activation energy and pre-exponential
    # factor as "raw" rate variable. Setuping it values provides trough
    # corresponding instance assertion methods.
    class UbiquitousReaction < Named
      # include Modules::ListsComparer

      # Exception class for cases when property already setted
      class AlreadySet < Exception
        attr_reader :property
        def initialize(property); @property = property end
      end

      class << self
      private
        # Defines some property setter by adding assertion method
        def define_property_setter(*properties)
          properties.each do |property|
            # Defines forward direction property setter
            # @raise [UbiquitousReaction::AlreadySet] if property already set
            # @param [Float] value the value of property
            define_method("#{property}=") do |value|
              var = "@#{property}".to_sym
              if instance_variable_get(var)
                raise UbiquitousReaction::AlreadySet.new(property)
              end
              instance_variable_set(var, value)
            end
          end
        end
      end

      define_property_setter :enthalpy, :activation, :rate
      attr_reader :source, :products #, :parent

      # Store source and product specs
      # @param [Symbol] type the type of reaction, can be :forward or :reverse
      # @param [Array] source the array of source specs
      # @param [Array] products the array of product specs
      def initialize(type, name, source, products)
        super(name)
        @type = type
        @source, @products = source, products
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

        # yield(@reverse) if block_given?
        # @reverse.parent = parent.reverse if parent
        @reverse
      end

      # Counts gases num in source specs scope
      # @return [Integer] number of specs that belongs to gas phase
      def gases_num
        @source.select { |v| v.is_gas? }.size
      end

  #     def to_s
  #       specs_to_s = -> specs { specs.map(&:to_s).join(' + ') }
  #       "#{specs_to_s[@source]} = #{specs_to_s[@products]}"
  #     end

  #     def visit(visitor)
  #       analyze_and_source_specs(visitor)

  #       if rate > 0
  #         accept_self(visitor)
  #       else
  #         visitor.accept_abstract_equation(self)
  #       end

  # # p @name
  # # puts "@@ rate: %1.3e" % rate
  # # return unless @atoms_map
  # # @atoms_map.each do |(source, product), indexes|
  # #   print "  #{source} => #{product} :: "
  # #   puts indexes.map { |one, two| "#{one} -> #{two}" }.join(', ')
  # # end
  #     end

  #     def same?(other)
  #       spec_compare = -> spec1, spec2 { spec1.same?(spec2) }
  #       lists_are_identical?(@source, other.source, &spec_compare) &&
  #         lists_are_identical?(@products, other.products, &spec_compare)
  #     end

  #     def dependent_from
  #       @dependent_from ||= []
  #     end

  #     def organize_dependencies(not_ubiquitous_equations)
  #       termination_specs = @source.select { |spec| spec.is_a?(TerminationSpec) }
  #       simple_specs = @source - termination_specs

  #       not_ubiquitous_equations.each do |possible_parent|
  #         simples_are_identical =
  #           lists_are_identical?(simple_specs, possible_parent.simple_source) do |spec1, spec2|
  #             spec1.same?(spec2)
  #           end
  #         next unless simples_are_identical

  #         terminations_are_covering =
  #           lists_are_identical?(termination_specs, possible_parent.complex_source) do |termination, complex|
  #             termination.cover?(complex)
  #           end
  #         next unless terminations_are_covering

  #         dependent_from << possible_parent
  #       end
  #     end

  #     def check_and_clear_parent_if_need
  #       return unless @parent
  #       # calling current .same? method for each child class
  #       unless same?(@parent)
  #       # unless UbiquitousEquation.instance_method(:same?).bind(self).call(@parent)
  #         @parent = nil
  #       end
  #     end

  #     def rate
  #       return 0 unless @rate
  #       @activation ||= 0

  #       r = @rate * Math.exp(-(@activation * 1000) /
  #         (Dimensions::R * current_temperature(source_gases_num)))
  #       @source.reduce(r) do |acc, spec|
  #         spec.is_gas? ? acc * Gas.instance[spec] : acc
  #       end
  #     end

    protected

      # attr_writer :parent
      attr_writer :reverse

    private

      # Makes params for reverse method
      def reverse_params
        [:reverse, @name, @products, @source]
      end

    #   def accept_self(visitor)
    #     visitor.accept_ubiquitous_equation(self)
    #   end

    #   def analyze_and_source_specs(visitor)
    #     @source.each { |spec| spec.visit(visitor) }
    #   end
    end

  end
end
