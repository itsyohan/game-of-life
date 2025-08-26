module GOL
  class Game
    PLAYBACK_SPEED_TO_SLEEP_DURATION = { '1' => 1, '2' => 0.8, '3' => 0.5, '4' => 0.3, '5' => 0.1, '6' => 0.05 }

    attr_reader :grid, :options

    def initialize(options)
      @options = options
      @grid = Grid.new(width: options.grid_width, height: (options.grid_width * 0.6).round)
      seed = Seed.load(options.seed_name)
      seed.cells do |cell|
        cell => { x:, y: }
        x_offset, y_offset = grid.center_coord
        grid.at(x + x_offset, y + y_offset).live! if cell.live?
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
      File.write("game.txt", grid_to_string(grid))
    end

    def grid_to_string(any_grid)
      any_grid.map { _1.join("") }.join("\n")
    end

    def prepare_new_grid
      # iterate over the grid and for each cell calculate the next state
      # the grid and cells remain unchanged and all the changes, the next states,
      # will be represented on a copied version of grid and cells
      new_grid = grid.deep_dup

      grid.cells do |cell|
        # get 8 neighbors, watch out for edges
        # (maybe) i can refactor with a coordinate object i.e coord.top_or_right_edge?
        cell => { x:, y: }
        n = grid.at(x, y-1) unless y == 0 # skip if top row
        ne = grid.at(x+1, y-1) unless y == 0 || x == grid.width - 1  # skip if top row or last cell in row
        e = grid.at(x+1, y) unless x == grid.width - 1  # skip if last cell in row
        se = grid.at(x+1, y+1) unless y == grid.height - 1 || x == grid.width - 1 # skip if last row or last cell in row
        s = grid.at(x, y+1) unless y == grid.height - 1 # skip if last row
        sw = grid.at(x-1, y+1) unless y == grid.height - 1 || x == 0 # skip if last row or first cell in row
        w = grid.at(x-1, y) unless x == 0 # skip if first cell in row
        nw = grid.at(x-1, y-1) unless y == 0 || x == 0 # skip if first row or first cell in row

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

        new_grid.set(Cell.new(new_state, x, y))

        if debug? && cell.live?
          debug_info(x:, y:, current_state: cell.state, new_state:, new_grid:, neighbor_count: live.count)
        end
      end

      new_grid
    end

    def debug?
      options.debug
    end

    def debug_info(x:, y:, current_state:, new_state:, new_grid:, neighbor_count:)
      debug_grid = grid.deep_dup
      debug_grid.set(Cell.new(:highlight, x, y))
      debug_grid.rows do |debug_row, debug_y|
        debug_row << "------->>"
        debug_row.concat(new_grid.row(debug_y))
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
end
