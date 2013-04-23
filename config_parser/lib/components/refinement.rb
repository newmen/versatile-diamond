require 'forwardable'

class Refinement < Component
  extend Forwardable
  include EquationProperties

  def initialize(equation)
    @equation = equation
  end

  def_delegators :equation_instance, :incoherent, :position

  def equation_instance
    @equation
  end
end
