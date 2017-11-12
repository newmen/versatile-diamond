module VersatileDiamond
  module Generators
    module Formula

      class CrystalMatrix
        # @param [Atom] start_atom
        def initialize(start_atom)
          @possible_steps = start_atom.lattice.instance.possible_steps
          @nodes = { 0 => { 0 => { 0 => MatrixNode.new(0, 0, 0, start_atom) } } }
          @size_ranges = {
            x: [0, 0],
            y: [0, 0],
            z: [0, 0],
          }
        end

        # @param [Bond] rel
        # @param [MatrixNode] node
        # @return [Array]
        def steps_by(rel, node)
          possible_steps[rel.params][node.x, node.y, node.z].map do |x, y, z|
            node_in(x, y, z)
          end
        end

        # @param [Atom] atom
        # @return [MatrixNode]
        def node_with(atom)
          nodes.each do |x, node_x|
            node_x.each do |y, node_xy|
              node_xy.each do |x, node_xyz|
                return node_xyz if node_xyz.atom == atom
              end
            end
          end
          raise ArgumentError, 'Atom was not added to matrix'
        end

      private

        attr_reader :possible_steps, :nodes, :size_ranges

        # @params [Integer] x, y, z
        # @return [MatrixNode]
        def node_in(x, y, z)
          extend_x!(-1) if x < size_ranges[:x][0]
          extend_x!(1) if x > size_ranges[:x][1]
          extend_y!(-1) if y < size_ranges[:y][0]
          extend_y!(1) if y > size_ranges[:y][1]
          extend_z!(-1) if z < size_ranges[:z][0]
          extend_z!(1) if z > size_ranges[:z][1]
          nodes[x][y][z]
        end

        # @param [Symbol] axis
        # @yield [Integer] index
        # @return [Range]
        def each_in(axis, &block)
          size_ranges[axis][0]..size_ranges[axis][1]
        end

        # @param [Symbol] axis
        # @param [Integer] dir (-1 or 1)
        # @return [Integer]
        def update_range!(axis, dir)
          size_ranges[axis][(dir + 1) / 2] += dir
        end

        # @param [Integer] dir (-1 or 1)
        def extend_x!(dir)
          new_x = update_range!(:x, dir)
          nodes[new_x] = {}
          each_in(:y) do |y|
            nodes[new_x][y] = {}
            each_in(:z) do |z|
              nodes[new_x][y][z] = MatrixNode.new(new_x, y, z)
            end
          end
        end

        # @param [Integer] dir (-1 or 1)
        def extend_y!(dir)
          new_y = update_range!(:y, dir)
          each_in(:x) do |x|
            nodes[x][new_y] = {}
            each_in(:z) do |z|
              nodes[x][new_y][z] = MatrixNode.new(x, new_y, z)
            end
          end
        end

        # @param [Integer] dir (-1 or 1)
        def extend_z!(dir)
          new_z = update_range!(:z, dir)
          each_in(:x) do |x|
            each_in(:y) do |y|
              nodes[x][y][new_z] = MatrixNode.new(x, y, new_z)
            end
          end
        end
      end

    end
  end
end
