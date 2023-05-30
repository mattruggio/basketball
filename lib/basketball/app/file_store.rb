# frozen_string_literal: true

module Basketball
  module App
    # Knows how to read and write documents to disk.
    class FileStore
      def read(path)
        File.read(path)
      end

      def write(path, contents)
        dir = File.dirname(path)

        FileUtils.mkdir_p(dir)

        File.write(path, contents)

        nil
      end
    end
  end
end
