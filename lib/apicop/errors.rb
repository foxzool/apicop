module APICop
  module Errors
    class APICopError < StandardError
    end

    class UnconfiguredError < APICopError
    end

    class InvalidAuthorizationStrategy < APICopError
    end

    class InvalidTokenStrategy < APICopError
    end

    class MissingRequestStrategy < APICopError
    end
  end
end
