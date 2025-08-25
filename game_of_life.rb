require 'optparse'
require "debug"

class Array
  def deep_dup
    map do |elem|
      if elem.is_a?(Array)
        elem.deep_dup
      else
        elem.dup
      end
    end
  end
end

class Cell
  COLORS = {
    dead: "⬛️",
    live: "⬜️",
    highlight: "🟥"
  }

  def self.colors(state)
    COLORS[state]
  end

  attr_reader :state

  def initialize(state)
    @state = state || :dead
  end

  def dead?
    @state == :dead
  end

  def live?
    @state == :live
  end

  def dead!
    @state = :dead
  end

  def live!
    @state = :live
  end

  def render
    COLORS[state]
  end

  alias_method :to_s, :render
end

class Game
  PLAYBACK_SPEED_TO_SLEEP_DURATION = { '1' => 1, '2' => 0.8, '3' => 0.5, '4' => 0.3, '5' => 0.1, '6' => 0.05 }

  attr_reader :grid, :options

  def initialize(options)
    @options = options
    width = options.grid_width
    height = (width * 0.6).round

    # Array.new { block } ensures array does not fill with the same objects
    #
    # TODO: create a Grid class like so - Grid.new(width:, height)
    # it would be nice to have an api like this grid.at(x, y)
    # because it's more readable and intuitive than grid[y][x]
    # OR
    # grid.cell(x, y) # reader
    # grid.cell = (x, y, value) # writer
    # grid.cell(x, y) = value # I want to do this but I don't think it's valid ruby
    # grid.cell(x, y).= value # but this is
    ### Grid ###
    # def cell(x, y)
    #  Cell.new(self, x, y)
    # end
    @grid = height.times.map { Array.new(width) { Cell.new(:dead) } }

    # x,y coordinates of the center
    # grid.length = outer array aka height
    center_coord = [(width / 2).round, (grid.length / 2).round]

    # seed coordinates represent coordinates relative to the center
    seed_coords = [[1,0],[0,1],[1,1],[1,2],[2,2]]
    seed_coords.each do |seed_coord|
      center_x, center_y = center_coord
      x, y = seed_coord
      # in order to access values in two dimensional array you have to
      # go in the reverse order y and x because outer array represents the height
      grid[center_y + y][center_x + x].live!
    end

    print_options
  end

  def play
    puts "starting..."
    @generation = 1

    loop do
      puts "generation ##{@generation}"

      render_grid
      @grid = prepare_new_grid
      @generation += 1

      if debug?
        gets
      else
        sleep(sleep_duration)
      end
    end
  end

  def render_grid
    File.write("output.txt", grid_to_string(grid))
  end

  def grid_to_string(any_grid)
    any_grid.map { _1.join("") }.join("\n")
  end

  def prepare_new_grid
    # iterate over the grid and for each cell calculate the next state
    # the grid and cells remain unchanged and all the changes, the next states,
    # will be represented on a copied version of grid and cells
    new_grid = grid.deep_dup

    grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        # get 8 neighbors, watch out for edges
        # (maybe) i can refactor with a coordinate object i.e coord.top_or_right_edge?
        n = grid[y-1][x] unless y == 0 # skip if top row
        ne = grid[y-1][x+1] unless y == 0 || x == row.length - 1  # skip if top row or last cell in row
        e = grid[y][x+1] unless x == row.length - 1  # skip if last cell in row
        se = grid[y+1][x+1] unless y == grid.length - 1 || x == row.length - 1 # skip if last row or last cell in row
        s = grid[y+1][x] unless y == grid.length - 1 # skip if last row
        sw = grid[y+1][x-1] unless y == grid.length - 1 || x == 0 # skip if last row or first cell in row
        w = grid[y][x-1] unless x == 0 # skip if first cell in row
        nw = grid[y-1][x-1] unless y == 0 || x == 0 # skip if first row or first cell in row

        live = [n,ne,e,se,s,sw,w,nw].compact.select(&:live?)

        # determine the next state for cell
        new_state = if cell.live? && live.count < 2
          :dead
        elsif cell.live? && [2,3].include?(live.count)
          :live
        elsif cell.live? && live.count >= 3
          :dead
        elsif cell.dead? && live.count == 3
          :live
        else
          :dead
        end

        new_grid[y][x] = Cell.new(new_state)

        if debug? && cell.live?
          debug_info(x:, y:, current_state: cell.state, new_state:, new_grid:, neighbor_count: live.count)
        end
      end
    end

    new_grid
  end

  def debug?
    options.debug
  end

  def debug_info(x:, y:, current_state:, new_state:, new_grid:, neighbor_count:)
    debug_grid = grid.deep_dup
    debug_grid[y][x] = Cell.new(:highlight)
    debug_grid.each_with_index do |debug_row, debug_y|
      debug_row << "------->>"
      debug_row.concat(new_grid[debug_y])
    end
    puts "x: #{x}, y: #{y}, state: #{current_state} -> #{new_state}, neighbors: #{neighbor_count}"
    puts grid_to_string(debug_grid)
    puts
  end

  def sleep_duration
    PLAYBACK_SPEED_TO_SLEEP_DURATION[options.playback_speed]
  end

  def print_options
    puts "running with following options:"
    puts "  #{options.to_h}"
    puts
  end
end

class Options
  attr_accessor :grid_width, :playback_speed, :debug

  def initialize
    @grid_width = 40
    @playback_speed = '1'
    @debug = false
  end

  def to_h
    { grid_width:, playback_speed:, debug: }
  end

  def self.get
    new.tap do |options|
      OptionParser.new do |op|
        op.on("-wWIDTH", "--width=WIDTH", "Control grid width. Defaults to 40") do |w|
          options.grid_width = w.to_i
        end

        op.on("-sSPEED", "--speed=SPEED", "Control playback speed 1-6. Defaults to 1") do |s|
          options.playback_speed = s
        end

        op.on("-d", "--debug", "Run in debugging mode") do |d|
          options.debug = d
        end
      end.parse!
    end
  end
end

Game.new(Options.get).play
