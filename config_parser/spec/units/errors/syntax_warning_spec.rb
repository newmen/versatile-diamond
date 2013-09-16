require 'spec_helper'

module VersatileDiamond
  module Errors

    describe SyntaxWarning, type: :errors do
      it_behaves_like "message for file"
    end

  end
end
