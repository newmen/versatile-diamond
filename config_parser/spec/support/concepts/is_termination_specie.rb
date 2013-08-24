module VersatileDiamond
  module Concepts
    module Support

      module IsTerminationSpecie
        shared_examples_for "termination spec" do
          it { subject.should be_a(TerminationSpec) }

          describe "#is_gas?" do
            it { subject.is_gas?.should be_false }
          end

          describe "#simple?" do
            it { subject.simple?.should be_false }
          end

          describe "#extendable?" do
            it { subject.extendable?.should be_false }
          end
        end
      end

    end
  end
end
