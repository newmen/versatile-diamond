require 'spec_helper'

module VersatileDiamond
  module Errors
    module Support

      module MessageForFileExamples
        shared_examples_for "message for file" do
          subject { described_class.new('hello') }

          describe "#message" do
            it { subject.message.should == "hello" }
            it { subject.message(2).should == "hello at line 2" }
            it { subject.message('/path', 0).should == "hello\n\tfrom /path:0" }
          end
        end
      end

    end
  end
end
