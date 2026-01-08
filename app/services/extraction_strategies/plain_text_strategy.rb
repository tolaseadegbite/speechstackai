module ExtractionStrategies
  class PlainTextStrategy
    def extract(io_stream)
      # Ensure we are at the start of the file
      io_stream.rewind if io_stream.respond_to?(:rewind)

      # Read the file and force UTF-8 to prevent encoding errors
      text = io_stream.read.to_s.force_encoding("UTF-8")

      # Basic cleanup: remove null bytes and trim whitespace
      text.gsub(/\0/, "").strip
    rescue StandardError => e
      "Error reading text file: #{e.message}"
    end
  end
end
