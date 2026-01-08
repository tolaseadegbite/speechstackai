class PdfExtractionsController < ApplicationController
  def create
    extracted_text = PdfTextExtractor.new(params[:pdf_file]).extract

    # Return JSON so Stimulus can insert it gracefully
    render json: { text: extracted_text }
  end
end
