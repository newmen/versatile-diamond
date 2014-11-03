module VersatileDiamond
  module Organizers

    # Provides additional methods for getting using atoms of dependent specie
    class DependentSpecReaction < DependentReaction
      %w(used changed).each do |prefix|
        method_name = :"#{prefix}_atoms_of"
        # Gets all using atoms of passed spec
        # @param [DependentWrappedSpec] spec the one of reactant
        # @return [Array] the array of using atoms
        define_method(method_name) do |dept_spec|
          reaction.public_send(method_name, dept_spec.spec)
        end
      end
    end

  end
end
