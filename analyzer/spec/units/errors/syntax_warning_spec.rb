require 'spec_helper'

module VersatileDiamond
  module Errors

    describe SyntaxWarning do
      it_behaves_like :message_for_file
    end

  end
end
