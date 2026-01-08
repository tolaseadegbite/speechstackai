class TextExtractor
  def self.extract(blob)
    # Get the file from ActiveStorage blob
    blob.open do |tempfile|
      strategy = case blob.content_type
      when "application/pdf"
                   ExtractionStrategies::PdfStrategy.new
      when "application/vnd.openxmlformats-officedocument.wordprocessingml.document" # .docx
                   ExtractionStrategies::DocxStrategy.new
      else
                   raise "Unsupported file type: #{blob.content_type}"
      end

      strategy.extract(tempfile)
    end
  end
end
