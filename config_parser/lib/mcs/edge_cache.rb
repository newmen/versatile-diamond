module VersatileDiamond

  class EdgeCache
    def initialize
      @cache = {}
    end

    def add(v, w)
      @cache[v] ||= Set.new
      @cache[v] << w
    end

    def has?(v, w)
      (@cache[v] && @cache[v].include?(w)) ||
        (@cache[w] && @cache[w].include?(v))
    end
  end

end
