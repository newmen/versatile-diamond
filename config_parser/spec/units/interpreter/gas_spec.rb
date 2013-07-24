module VersatileDiamond
  module Interpreter

    describe Gas do
      describe "#spec" do
        it "interpreted spec stores in chest" do
          Gas.new.interpret('spec :hello').should be_a(Interpreter::GasSpec)
          Tools::Chest.spec(:hello).should be_a(Concepts::GasSpec)
        end
      end
    end

  end
end
