module GOL
  class Grid
    #
    ### Motivation
    #
    # When you are dealing with a grid, typically you would have something like this:
    #
    # grid = [ y0[ x0... ], y1[ x0... ], y2[ x0... ] ]
    # grid.each_with_index do |outside, y|
    #   outside.each_with_index do |inside, x|
    #     # access element
    #     element = grid[y][x]
    #
    #     # access neighbor to the right
    #     neighbor = grid[y][x+1]
    #     ...
    #   end
    # end
    #
    # You have a nested array in which you have to remember which indices represent x and y coordinates.
    # And if you have not worked with grids in a while, this can trip you up because you have to write them
    # in the reverse order - y and x not x and y.
    #
    # By having a Grid class you can simplify a lot of this and have a more intuitive and human friendly interface:
    #
    #   grid.cells do |cell|
    #     # get the neighbor to the right
    #     grid.at(cell.x+1, cell.y)
    #     ...
    #   end
    #
    # You flatten the nested array and encapsulate traversing the grid with a single #cells method.
    # The cell object knows where it is on the grid with x and y properties. And you can access any cell on the grid
    # with the grid #at method which takes x and y values as arguments.
    #
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
      end
    end

    def fill
      @grid = height.times.map { |y| width.times.map { |x| yield(x, y) } }
      self
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
