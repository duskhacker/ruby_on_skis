module Extensions
  module String
    module Truncate

      def truncate(size = 20)
        ellipsis = "..."
        return self if size < ellipsis.size  || self.size == ellipsis.size
        size -= ellipsis.size
        self.size > size ? self.slice(0,size) + "..." : self
      end

    end
  end
end

String.send :include,  Extensions::String::Truncate
