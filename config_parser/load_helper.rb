def files_in(path)
  Dir["#{__dir__}/#{path}"]
end

def require_each(path)
  files_in(path).each { |filename| require filename }
end

def find_dir(filename, *pathes)
  pathes.each do |path|
    files_in("#{path}/**/*.rb").each do |full_path|
      match = full_path.match(/(\w+)\/(\w+).rb\Z/)
      if match[2] == filename
        return match[1]
      end
    end
  end
  nil
end
