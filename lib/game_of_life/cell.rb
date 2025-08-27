module GOL
  class Cell
    COLORS = {
      dead: "⬛️",
      live: "⬜️",
      highlight: "🟥"
    }

    def self.colors(state)
      COLORS[state]
    end

    attr_reader :state, :x, :y

    def initialize(state, x, y)
      @state = state || :dead
      @x = x
      @y = y
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

    def x?
      !@x.nil?
    end

    def y?
      !@y.nil?
    end

    def render
      COLORS[state]
    end

    def deconstruct_keys(_keys)
      to_h
    end

    def to_h
      { state:, x:, y: }
    end

    alias_method :to_s, :render
  end
end
