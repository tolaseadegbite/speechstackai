class PdfTextExtractor
  def initialize(file)
    @file = file
  end

  def extract
    return "" unless @file

    # Grab the underlying IO stream
    io_stream = @file.respond_to?(:tempfile) ? @file.tempfile : @file

    reader = PDF::Reader.new(io_stream)

    # Extract text from all pages
    raw_text = reader.pages.map(&:text).join("\n")

    clean_text(raw_text)
  rescue StandardError => e
    "Error parsing PDF: #{e.message}"
  end

  private

  def clean_text(text)
    # 1. REMOVE PAGE NUMBERS
    # We filter out lines that contain ONLY digits or patterns like "Page 1"
    # This prevents "3" appearing in the middle of your text.
    lines = text.lines.reject do |line|
      clean_line = line.strip
      # Match "1", "45", "Page 2", "2 of 4"
      clean_line.match?(/\A(\d+|Page\s+\d+|Seite\s+\d+)\z/i) || clean_line.empty?
    end

    # Rejoin strictly for processing
    text = lines.join("\n")

    # 2. FIX BROKEN SENTENCES (The "knowing... that" issue)
    # Explanation of Regex:
    # (?<=[^\.\?\!])   -> Lookbehind: Ensure previous char is NOT a sentence ender (., ?, !)
    # \n+              -> Match one or more newlines
    # \s*              -> Match optional whitespace
    # (?=[a-z])        -> Lookahead: Ensure next char is a lowercase letter
    #
    # Result: If a line ends without punctuation and the next starts with lowercase,
    # it joins them with a space instead of a newline.
    text = text.gsub(/(?<=[^\.\?\!"”])\n+\s*(?=[a-z])/, " ")

    # 3. NORMALIZE PARAGRAPHS
    # Now that sentences are joined, we treat remaining double newlines as paragraphs
    text = text.split(/\n\s*\n/).map do |para|
      # Replace single newlines within a paragraph with space and squeeze spaces
      para.gsub("\n", " ").squeeze(" ").strip
    end.join("\n\n")

    text.strip
  end
end
