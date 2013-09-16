require 'tempfile'

module VersatileDiamond
  module Tools

    # Provides method for catch stdout result
    module StdoutCatcher

      # Catches stdout result message
      # @param [Proc] proc the proc which do some action stdout of which will
      #   be catched
      # @yield [String] do something with catched message
      # @return result of passed block or message if block is not given
      def catch_stdout(proc, &block)
        tempout = Tempfile.new('tempout')
        out_backup = $stdout
        $stdout = tempout

        proc.call

        $stdout = out_backup
        tempout.rewind
        message = tempout.read.chomp

        block_given? ? block[message] : message
      ensure
        tempout.close
        tempout.unlink
      end
    end

  end
end
