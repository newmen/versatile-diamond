class Position
  def self.[](face, dir = nil)
    key = face.to_s
    key << "_#{dir}" if dir
    @consts ||= {}
    @consts[key] ||= new(face, dir)
  end

  def initialize(face, dir)
    @face, @dir = face, dir
  end
end
