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
            expect(mapping_result.full).to eq(full)
          end

          it "map and associate changed" do
            expect(mapping_result.changes).to eq(changed)
          end
        end
      end

    end
  end
end
