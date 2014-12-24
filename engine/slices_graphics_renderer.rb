#!/usr/bin/env ruby

require 'docopt'
require 'gnuplot'
require 'pathname'
require 'singleton'

# Provides logic for working with command line through docopt
class PlotsConfig
  include Singleton

  attr_reader :coding, :dir, :filename, :format,
              :font, :fontsize,
              :linetype, :linewidth, :size,
              :notitles, :nolabels

  # Accumulates passed options and setup internal variables for each option
  def initialize
    options = Docopt::docopt(doc)
    @filename = options.delete('<filename.sls>')

    raise Docopt::Exit, 'File not exists' unless File.exist?(@filename)
    raise Docopt::Exit, 'File has a wrong format' unless @filename =~ /\.sls\Z/

    options.each do |dashed_k, v|
      k = dashed_k[2..dashed_k.length]
      instance_variable_set("@#{k}".to_sym, v)
    end
  end

  # Builds path to result files
  # @param [String] filename the name of result file without directory and format
  # @return [String] full path to file
  def filepath(filename)
    path = Pathname.new("#{filename}.#{@format}")
    if @dir
      Dir.mkdir(@dir) unless Dir.exist?(@dir)
      path = Pathname.new(@dir) + path
    end

    path.to_s
  end

  # Provides string by which gnuplot setups font
  # @return [String] string of gnuplot font configuration
  def font_setup
    %Q(font "#{@font},#{@fontsize}")
  end

private

  # Contain help text which is used by docopt
  # @return [String] help (documentation) text
  def doc
<<HEREHELP
Usage:
  #{__FILE__} <filename.sls> [options]

Options:
  -h, --help                This help
  -c, --coding=encode       Encoding inscriptions, in the case of format eps (cp1251|uft8) [default: cp1251]
  -d, --dir=directory       Directory with results
  -f, --format=ext          Format of output files (png|eps|svg) [default: png]
  -l, --linetype=type       Type of lines (lines|linespoints|points) [default: linespoints]
  -w, --linewidth=width     Width of lines [default: 1]
  -s, --size=width,height   Size of plots when output file has png format
  --font=fontname           Font to be used when output file is not png format [default: Times-New-Roman]
  --fontsize=size           Font size to be used when output file is not png format [default: 32]
  --notitles                Not include titles in pictures
  --nolabels                Not include axis labels in pictures
HEREHELP
  end
end

# Provides instance of current configuration options
# @return [PlotsConfig] config which contains passed options by command line
def config
  PlotsConfig.instance
end

# Reads SLS file
# @return [Array] the array where the first item is types of atoms and the second item
#   is concentrations of each atom type
def read_slices
  types, concs = nil
  File.open(config.filename) do |f|
    lines = f.readlines
    types = lines.shift.scan(/\d+/)
    concs = types.map { Hash.new }

    curr_time = nil
    curr_slice = nil
    lines.each do |original_line|
      line = original_line.strip
      next if line.empty?
      if m = line.match(/\= (\d+(?:\.\d+(?:e-?\d+)?)?)/)
        curr_time = m[1].to_f
        curr_slice = 0
      else
        raise %Q(Not found line with time before "#{line}") unless curr_time
        values = line.split(/\s+/).map(&:to_f)
        values.each_with_index do |value, i|
          concs[i][curr_slice] ||= {}
          concs[i][curr_slice][curr_time] = value
        end
        curr_slice += 1
      end
    end
  end

  [types, concs]
end

# Makes gnuplot dataset and pass it in block
# @param [Array] data for which dataset will be maked
# @yield [Gnuplot::DataSet] do something with maked dataset
def data_set(data, &block)
  Gnuplot::DataSet.new(data) do |ds|
    ds.with = config.linetype
    ds.linewidth = config.linewidth
    block.call(ds) if block_given?
  end
end

# Makes gnuplot result file
# @param [String] filename the name of result file
# @param [String] title of result plot
# @param [String] xlabel the label of X axis
# @param [String] ylabel the label of Y axis
# @yield [Gnuplot::Plot] do something with internal plot instance
def make_gnuplot(filename, title, xlabel, ylabel, &block)
  Gnuplot.open do |gp|
    Gnuplot::Plot.new(gp) do |plot|
      plot.output("#{config.filepath(filename)}")
      case config.format
      when 'eps'
        plot.set("enc #{config.coding}")
        plot.set("term postscript eps #{config.font_setup}")
      when 'png'
        plot.set('terminal png')
        plot.set('terminal png size #{config.size}') if config.size
      else
        plot.set("terminal #{config.format}")
        # plot.set("terminal #{config.format} #{config.font_setup}")
      end

      plot.set("key off")

      plot.title(title) unless config.notitles
      unless config.nolabels
        plot.xlabel(xlabel)
        plot.ylabel(ylabel)
      end

      block.call(plot)
    end
  end
end

# Makes all result plot files
# @param [Array] types the array of saved atom types
# @param [Array] concs the array of concentration for each atom type, where each item
#  is hash where keys are time labels and values are concentration values
def render_graphics(types, concs)
  types.zip(concs) do |type, slices|
    make_gnuplot(type, "#{type} atom type", 'time (s)', 'concentration (%)') do |plot|
      # plot.yrange('[0:1]')
      plot.data += slices.map do |n, slice|
        data_set([slice.keys, slice.values])
      end
    end
  end
end

# The entry point
def main
  render_graphics(*read_slices)
rescue Docopt::Exit => e
  puts e.message
end

main
