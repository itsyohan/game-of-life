require "debug"
class Cell
  COLORS = {
    dead: "⬛️",
    live: "⬜️"
  }

  def self.colors(color)
    COLORS[color]
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

width = 40
height = (width * 0.6).round

# Array.new { block } ensures array does not fill with the same objects
grid = height.times.map { Array.new(width) { Cell.new(:dead) } }

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

generation = 1
loop do
  output = grid.map { _1.join("") }.join("\n")
  puts "generation ##{generation}"
  File.write("output.txt", output)

  # iterate over the grid and for each cell calculate the next state
  # the grid and cells remain unchanged and all the changes, the next states,
  # will be represented on a copied version of grid and cells
  new_grid = grid.dup
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

      # determine the next state for cell
      live = [n,ne,e,se,s,sw,w,nw].compact.select(&:live?)

      new_state = if cell.live? && live.count < 2
        :dead
      elsif cell.live? && [2.3].include?(live.count)
        :live
      elsif cell.live? && live.count >= 3
        :dead
      elsif cell.dead? && live.count == 3
        :live
      else
        :dead
        # raise "unhandled state: #{cell.state}, live neighbor count: #{live.count}"
      end

      new_grid[y][x] = Cell.new(new_state)
    end
  end

  sleep(1)
  generation += 1
  grid = new_grid
end
