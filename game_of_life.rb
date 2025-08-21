square = "⬛️"
width = 40
height = (width * 0.6).round

# loop do
  grid = height.times.map { Array.new(width, square) }
  # returns x,y coordinates of the center
  # grid.length = outer array aka height
  center_coord = [(width / 2).round, (grid.length / 2).round]
  # seed coordinates represent coordinates relative to the center
  seed_coords = [[1,0],[0,1],[1,1],[1,2],[2,2]]
  seed_coords.each do |seed_coord|
    center_x, center_y = center_coord
    x, y = seed_coord
    # in order to access values in two dimensional array you have to
    # go in the reverse order y and x because outer array represents the height
    grid[center_y + y][center_x + x] = "⬜️"
  end
  output = grid.map { _1.join("") }.join("\n")
  File.write("output.txt", output)
  # sleep(1)
# end
