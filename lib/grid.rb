module GOL
  class Grid
    def self.from(array)
      wrapped = array.map do |rows|
        rows.map do |cell|
          # FIXME: don't use emojis for seeds
          if cell + "️" == Cell.colors(:live)
            Cell.new(:live)
          else
            Cell.new(:dead)
          end
        end
      end
      new(grid: wrapped)
    end

    attr_reader :width, :height, :grid

    def initialize(width: nil, height: nil, grid: nil)
      if grid
        @width = grid[0].length
        @height = grid.length
        @grid = grid
      else
        @width = width
        @height = height
        @grid = height.times.map { Array.new(width) { Cell.new(:dead) } }
      end
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

    def center_coord
      [(width / 2).round, (height / 2).round]
    end

    def deep_dup
      dup.tap do |dupped|
        dupped.instance_variable_set(:@grid, grid.deep_dup)
      end
    end
  end
end
