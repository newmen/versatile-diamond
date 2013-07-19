module VersatileDiamond

  class Run < Component
    include Singleton

    def total_time(value, dimension = nil)
      @total_time = Dimensions.convert_time(value, dimension)
    end
  end

end
