module GOL
  class Grid
    def self.from(array)
      wrapped = array.map.with_index do |rows, y|
        rows.map.with_index do |state, x|
          if state == :live
            Cell.new(:live, x, y)
          else
            Cell.new(:dead, x, y)
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
        @grid = height.times.map { |y| width.times.map { |x| Cell.new(:dead, x, y) } }
      end
    end

    def at(x, y)
      grid[y][x]
    end

    def set(cell)
      raise ArgumentError, "x, y must be set on Cell object" unless cell.x? && cell.y?
      grid[cell.y][cell.x] = cell
    end

    def cells
      return rows.flatten unless block_given?

      rows do |row|
        row.each do |cell|
          yield(cell)
        end
      end
    end

    def rows
      if block_given?
        grid.each do |row|
          yield(row)
        end
      else
        grid
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
