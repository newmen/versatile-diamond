module VersatileDiamond
  module Organizers

    # Provides methods by which dependent instances could be inspected when debug
    module InspecableDependentInstance
      def to_s
        "(#{name}, [#{parents.map(&:name).join(' ')}], " +
          "[#{children.map(&:name).join(' ')}])"
      end

      def inspect
        to_s
      end
    end

  end
end
