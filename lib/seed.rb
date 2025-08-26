module GOL
  module Seed
    def self.load(seed_name)
      # beware: this is not a normal empty string
      File.read("seeds/#{seed_name}.txt")
        .split("\n")
        .map { _1.split("").reject { |s| s == "️" } }
        .then { Grid.from(_1) }
    end
  end
end
