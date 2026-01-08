module ExtractionStrategies
  class PdfStrategy
    def extract(io_stream)
      reader = PDF::Reader.new(io_stream)
      raw_text = reader.pages.map(&:text).join("\n")

      # Check if PDF was scanned (empty text)
      if raw_text.strip.empty?
        return "[System]: No text could be extracted. This appears to be a scanned document or contains only images."
      end

      clean_text(raw_text)
    rescue StandardError => e
      "Error parsing PDF: #{e.message}"
    end

    private

    def clean_text(text)
      # Remove page numbers
      lines = text.lines.reject { |l| l.strip.match?(/\A(\d+|Page\s+\d+)\z/i) }
      text = lines.join("\n")

      # Fix broken sentences (knowing \n that -> knowing that)
      text = text.gsub(/(?<=[^\.\?\!"”])\n+\s*(?=[a-z])/, " ")

      # Normalize paragraphs
      text.split(/\n\s*\n/).map do |para|
        para.gsub("\n", " ").squeeze(" ").strip
      end.join("\n\n").strip
    end
  end
end
