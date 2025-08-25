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
end
