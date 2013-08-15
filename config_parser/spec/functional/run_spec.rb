require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Run, type: :interpreter do
      before(:each) { Tools::Config.reset }

      let(:run) { Run.new }
      it { expect { run.interpret('total_time 55, min') }.
        not_to raise_error }
    end

  end
end