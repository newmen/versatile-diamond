#!/usr/bin/env ruby

require 'fileutils'

IMG_EXT = '.png'
MOV_EXT = '.mp4'

dir = ARGV[0]
out_name = ARGV[1] || 'out'

def max_image_name_length(sorted_images)
  sorted_images.last.size - IMG_EXT.size
end

def check_and_rename(sorted_images, max_length)
  sorted_images.each_with_index do |name, i|
    basename = File.basename(name, IMG_EXT)
    index = basename.scan(/^0*?(0|\d+)$/).first.first.to_i

    if i != index
      i_str = i.to_s
      i_str_length = i_str.size
      zeros_num = max_length - i_str_length
      new_name = ('0' * zeros_num) + i_str + IMG_EXT

      puts %Q(Rename "#{name}" to "#{new_name}")
      FileUtils.mv(name, new_name)
    end
  end
end

if dir && Dir.exist?(dir)
  Dir.chdir(dir)

  sorted_images = Dir["*#{IMG_EXT}"].sort
  max_length = max_image_name_length(sorted_images)
  check_and_rename(sorted_images, max_length)

  movie_name = "#{out_name}#{MOV_EXT}"
  `ffmpeg -i %0#{max_length}d.png -c:v libx264 -pix_fmt yuv420p #{movie_name}`
else
  puts "Wrong passed directory"
end
