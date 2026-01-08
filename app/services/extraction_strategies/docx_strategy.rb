require "docx"

module ExtractionStrategies
  class DocxStrategy
    def extract(io_stream)
      # Docx gem needs a file path or a rewindable stream
      doc = Docx::Document.open(io_stream)

      doc.paragraphs.map do |p|
        p.text.to_s.strip
      end.reject(&:empty?).join("\n\n")
    rescue StandardError => e
      "Error parsing DOCX: #{e.message}"
    end
  end
end
