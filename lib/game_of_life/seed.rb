module GOL
  module Seed
    def self.load(seed_name)
      mapping = { 'X' => :dead, 'O' => :live }
      File.read("seeds/#{seed_name}.txt")
        .split("\n")
        .map { _1.split("").map { |char| mapping[char] } }
        .then { Grid.from(_1) }
    end
  end
end
