class TextExtractor
  def self.extract(blob)
    blob.open do |tempfile|
      strategy = case blob.content_type
      when "application/pdf"
                   ExtractionStrategies::PdfStrategy.new
      when "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                   ExtractionStrategies::DocxStrategy.new
      when "text/plain"
                   ExtractionStrategies::PlainTextStrategy.new
      else
                   # RAISE error so the Job catches it
                   raise "Unsupported file type: #{blob.content_type}. Please upload PDF, DOCX, TXT, or Image."
      end

      strategy.extract(tempfile)
    end
  end
end
