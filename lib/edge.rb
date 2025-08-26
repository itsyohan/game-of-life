module GOL
  class Edge
    def initialize(grid, cell)
      @grid = grid
      @x = cell.x
      @y = cell.y
    end

    def top_or_right?
      top? || right?
    end

    def bottom_or_right?
      bottom? || right?
    end

    def bottom_or_left?
      bottom? || left?
    end

    def top_or_left?
      top? || left?
    end

    def top?
      y == 0
    end

    def bottom?
      y == grid.height - 1
    end

    def left?
      x == 0
    end

    def right?
      x == grid.width - 1
    end

    private

    attr_reader :grid, :x, :y
  end
end
