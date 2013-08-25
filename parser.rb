#!/usr/bin/env ruby

require 'docopt'
require_relative 'config_parser/config_parser'

doc = <<HELP
Usage:
  #{__FILE__} <path_to_config> [options]

Options:
  -h, --help        Show this screen
  --lang=LANGUAGE   Setup current language [default: ru]
HELP

begin
  opt = Docopt::docopt(doc)
  I18n.locale = opt['--lang']

  VD = VersatileDiamond

  VD::Analyzer.read_config(opt['<path_to_config>'])

  graph_vizualizer = VD::Visitors::GraphVizualizer.new('total_tree')
  VD::Tools::Chest.visit(graph_vizualizer)
  graph_vizualizer.generate

rescue Docopt::Exit => e
  puts e.message
end
