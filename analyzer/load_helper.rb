# Gets list of files by passed mask
# @param [String] path_mask the mask for finging files
# @return [Array] the list of files that corresponds to passed mask
def files_in(path_mask)
  Dir["#{__dir__}/#{path_mask}"]
end

# Requires all files that could be found by passed mask
# @param [String] path_mask see at #files_in same argument
def require_each(path_mask)
  files_in(path_mask).each { |filename| require filename }
end
