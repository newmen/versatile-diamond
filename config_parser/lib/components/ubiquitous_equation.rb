module VersatileDiamond

  class UbiquitousEquation < ComplexComponent
    include ListsComparer

    class << self
    private
      def define_property_setter(property)
        define_method("forward_#{property}=") do |value, prefix = :forward|
          if instance_variable_get("@#{property}".to_sym)
            syntax_error("equation.#{property}_already_set")
          end

          update_attribute(property, value, prefix)
        end

        define_method("reverse_#{property}=") do |value|
          reverse.send("forward_#{property}=", value, :reverse)
        end
      end
    end

    attr_reader :name, :source, :products, :parent

    def initialize(name, source_specs, products_specs)
      @name = name
      @source, @products = source_specs, products_specs
    end

    %w(source products).each do |specs|
      define_method("#{specs}_gases_num") do
        instance_variable_get("@#{specs}".to_sym).map(&:is_gas?).
          select { |v| v }.size
      end
    end

    def enthalpy=(value)
      self.forward_enthalpy = value
      self.reverse_enthalpy = -value
    end

    define_property_setter :activation
    define_property_setter :rate

    def to_s
      specs_to_s = -> specs { specs.map(&:to_s).join(' + ') }
      "#{specs_to_s[@source]} = #{specs_to_s[@products]}"
    end

    def visit(visitor)
      @source.each { |spec| spec.visit(visitor) }

      if @activation && @rate
        accept_self(visitor)
      else
        visitor.accept_abstract_equation(self)
      end
    end

    def same?(other)
      spec_compare = -> spec1, spec2 { spec1.same?(spec2) }
      lists_are_identical?(@source, other.source, &spec_compare) &&
        lists_are_identical?(@products, other.products, &spec_compare)
    end

    def dependent_from
      @dependent_from ||= []
    end

    def organize_dependencies(not_ubiquitous_equations)
      termination_specs = @source.select { |spec| spec.is_a?(TerminationSpec) }
      simple_specs = @source - termination_specs

      not_ubiquitous_equations.each do |possible_parent|
        simples_are_identical =
          lists_are_identical?(simple_specs, possible_parent.simple_source) do |spec1, spec2|
            spec1.same?(spec2)
          end
        next unless simples_are_identical

        terminations_are_covering =
          lists_are_identical?(termination_specs, possible_parent.complex_source) do |termination, complex|
            termination.cover?(complex)
          end
        next unless terminations_are_covering

        dependent_from << possible_parent
      end
    end

  protected

    attr_writer :parent

    def reverse
      return @reverse if @reverse

      @reverse = Equation.register(self.class.new(*reverse_params))
      @name << ' forward'
      yield(@reverse) if block_given?
      @reverse.parent = parent.reverse if parent
      @reverse
    end

  private

    define_property_setter :enthalpy

    def reverse_params
      ["#{@name} reverse", @products, @source]
    end

    def update_attribute(attribute, value, prefix = nil)
      instance_variable_set("@#{attribute}".to_sym, value)
    end

    def accept_self(visitor)
      visitor.accept_ubiquitous_equation(self)
    end
  end

end
