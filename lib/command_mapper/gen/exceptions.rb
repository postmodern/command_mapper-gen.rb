module CommandMapper
  module Gen
    class Error < RuntimeError
    end

    class CommandNotInstalled < Error
    end
  end
end
