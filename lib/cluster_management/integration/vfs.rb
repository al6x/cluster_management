module Vfs
  class File
    def render *args
      args.unshift Object.new if args.size == 1 and args.first.is_a?(Hash)
      Tilt::ERBTemplate.new(path).render *args
    end
  end
end