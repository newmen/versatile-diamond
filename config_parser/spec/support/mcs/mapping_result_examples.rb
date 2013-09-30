module VersatileDiamond
  module Mcs
    module Support

      module MappingResultExamples
        shared_examples "check mapping result" do
          let(:mapping_result) do
            s = respond_to?(:source) ? source : [spec1, spec2]
            p = respond_to?(:products) ? products : [spec3]
            MappingResult.new(s, p)
          end

          before(:each) { subject } # do atom mapping

          it "map and associate all" do
            mapping_result.full.should == full
          end

          it "map and associate changed" do
            mapping_result.changes.should == changed
          end
        end
      end

    end
  end
end
