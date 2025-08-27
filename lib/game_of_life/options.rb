require 'optparse'

module GOL
  class Options
    attr_accessor :grid_width, :playback_speed, :seed_name, :debug

    def initialize
      @grid_width = 40
      @playback_speed = '1'
      @seed_name = 'kevin'
      @debug = false
    end

    def to_h
      { grid_width:, playback_speed:, seed_name:, debug: }
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

          op.on("-seSEED", "--seed=SEED", "Choose a seed file") do |s|
            options.playback_speed = s
          end

          op.on("-d", "--debug", "Run in debugging mode") do |d|
            options.debug = d
          end
        end.parse!
      end
    end
  end
end
