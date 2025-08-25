# require "debug"

require_relative 'cell'
require_relative 'core_ext'
require_relative 'game'
require_relative 'options'

module GOL
  def self.play
    Game.new(options).play
  end

  def self.options
    Options.get
  end
end
