module GOL
  class Grid
    attr_reader :width, :height, :grid

    def initialize(width, height)
      @width = width
      @height = height
      @grid = height.times.map { Array.new(width) { Cell.new(:dead) } }
    end

    def at(x, y)
      grid[y][x]
    end

    def set(x, y, value)
      grid[y][x] = value
    end

    def cells
      rows do |row, y|
        row.each_with_index do |cell, x|
          yield(cell, x, y)
        end
      end
    end

    def rows
      grid.each_with_index do |row, y|
        yield(row, y)
      end
    end

    def row(index)
      grid[index]
    end

    def map(&)
      grid.map(&)
    end

    def deep_dup
      dup.tap do |dupped|
        dupped.instance_variable_set(:@grid, grid.deep_dup)
      end
    end
  end
end
