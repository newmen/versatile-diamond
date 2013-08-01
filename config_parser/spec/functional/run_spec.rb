require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Run do
      before(:each) { Tools::Config.reset }

      let(:run) { Run.new }
      it { -> { run.interpret('total_time 55, min') }.
        should_not raise_error Exception }
    end

  end
end