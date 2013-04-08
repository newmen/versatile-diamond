#!/usr/bin/env ruby

require 'docopt'
require_relative 'config_parser/config_parser'

doc = <<HELP
Usage:
  #{__FILE__} <path_to_config> [options]

Options:
  -h, --help     Show this screen
HELP

begin
  opt = Docopt::docopt(doc)
  config = File.read(opt['<path_to_config>'])
  Analizer.analize(config)

  p Spec[:bridge]

rescue Docopt::Exit => e
  puts e.message
end
