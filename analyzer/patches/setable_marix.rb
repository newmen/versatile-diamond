require 'matrix'

module VersatileDiamond
  module Patches

    # Provides setable method for matrix
    class SetableMatrix < Matrix
      public :'[]='
    end

  end
end
