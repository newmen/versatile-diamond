require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Run do
      it { Run.new.total_time(55, 'min').should be_nil }
    end

  end
end