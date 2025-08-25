class Array
  def deep_dup
    map do |elem|
      if elem.is_a?(Array)
        elem.deep_dup
      else
        elem.dup
      end
    end
  end
end
