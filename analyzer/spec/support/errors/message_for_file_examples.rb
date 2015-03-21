module VersatileDiamond
  module Errors
    module Support

      module MessageForFileExamples
        shared_examples_for :message_for_file do
          subject { described_class.new('hello') }

          describe '#message' do
            it { expect(subject.message).to eq('hello') }
            it { expect(subject.message(2)).to eq('hello at line 2') }
            it { expect(subject.message('/path', 0)).
              to eq("hello\n\tfrom /path:0") }
          end
        end
      end

    end
  end
end
