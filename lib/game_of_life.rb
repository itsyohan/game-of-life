require "debug"

require_relative 'core_ext'
require_relative 'game_of_life/cell'
require_relative 'game_of_life/edge'
require_relative 'game_of_life/game'
require_relative 'game_of_life/grid'
require_relative 'game_of_life/options'
require_relative 'game_of_life/seed'

module GOL
  def self.play
    Game.new(options).play
  end

  def self.options
    Options.get
  end
end
