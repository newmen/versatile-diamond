module VersatileDiamond
  module Generators
    module Formula

      class CrystalMatrix
        # @param [Atom] start_atom
        def initialize(start_atom)
          @possible_steps = start_atom.lattice.instance.possible_steps
          @all_nodes = { 0 => { 0 => { 0 => MatrixNode.new(0, 0, 0, start_atom) } } }
          @size_ranges = {
            x: [0, 0],
            y: [0, 0],
            z: [0, 0],
          }
        end

        # @yield [MatrixNode]
        def each_nonempty(&block)
          enumerate.select(&:atom).each(&block)
        end

        # @param [Atom] atom
        # @return [MatrixNode]
        def node_with(atom)
          each_nonempty.find { |node| node.atom == atom }
        end

        # @param [Bond] rel
        # @param [MatrixNode] node
        # @return [Array]
        def steps_by(rel, node)
          possible_steps[rel.params][*node.coords].map { |coords| node_in(*coords) }
        end

      private

        attr_reader :possible_steps, :all_nodes, :size_ranges

        # @return [Enumerator]
        def enumerate
          Enumerator.new do |enum|
            all_nodes.each do |_, x_nodes|
              x_nodes.each do |_, xy_nodes|
                xy_nodes.each { |_, xyz_node| enum << xyz_node }
              end
            end
          end
        end

        # @params [Integer] x, y, z
        # @return [MatrixNode]
        def node_in(x, y, z)
          extend_x!(-1) if x < size_ranges[:x][0]
          extend_x!(1) if x > size_ranges[:x][1]
          extend_y!(-1) if y < size_ranges[:y][0]
          extend_y!(1) if y > size_ranges[:y][1]
          extend_z!(-1) if z < size_ranges[:z][0]
          extend_z!(1) if z > size_ranges[:z][1]
          all_nodes[x][y][z]
        end

        # @param [Symbol] axis
        # @yield [Integer] index
        # @return [Range]
        def each_in(axis, &block)
          (size_ranges[axis][0]..size_ranges[axis][1]).each(&block)
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
          all_nodes[new_x] = {}
          each_in(:y) do |y|
            all_nodes[new_x][y] = {}
            each_in(:z) do |z|
              all_nodes[new_x][y][z] = MatrixNode.new(new_x, y, z)
            end
          end
        end

        # @param [Integer] dir (-1 or 1)
        def extend_y!(dir)
          new_y = update_range!(:y, dir)
          each_in(:x) do |x|
            all_nodes[x][new_y] = {}
            each_in(:z) do |z|
              all_nodes[x][new_y][z] = MatrixNode.new(x, new_y, z)
            end
          end
        end

        # @param [Integer] dir (-1 or 1)
        def extend_z!(dir)
          new_z = update_range!(:z, dir)
          each_in(:x) do |x|
            each_in(:y) do |y|
              all_nodes[x][y][new_z] = MatrixNode.new(x, y, new_z)
            end
          end
        end
      end

    end
  end
end
