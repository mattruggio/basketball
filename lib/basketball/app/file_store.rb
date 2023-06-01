# frozen_string_literal: true

module Basketball
  module App
    # Knows how to read and write documents to disk.
    class FileStore
      class PathNotFoundError < StandardError; end

      def exist?(path)
        File.exist?(path)
      end

      def read(path)
        raise PathNotFoundError, "'#{path}' not found" unless exist?(path)

        File.read(path)
      end

      def write(path, contents)
        dir = File.dirname(path)

        FileUtils.mkdir_p(dir)

        File.write(path, contents)

        nil
      end

      def delete(path)
        raise PathNotFoundError, "'#{path}' not found" unless exist?(path)

        File.delete(path)

        nil
      end
    end
  end
end
