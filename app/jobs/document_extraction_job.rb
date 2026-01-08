class DocumentExtractionJob < ApplicationJob
  queue_as :text_extraction

  def perform(blob_id, stream_id)
    blob = ActiveStorage::Blob.find(blob_id)

    begin
      extracted_text = TextExtractor.extract(blob)

      # SUCCESS: Broadcast text to the hidden div
      broadcast_result(stream_id, text: extracted_text)

    rescue StandardError => e
      # ERROR 1: Broadcast the Flash Message
      # We target "flash_messages" (ensure this ID exists in your layout)
      Turbo::StreamsChannel.broadcast_prepend_to(
        "document_extractions_#{stream_id}",
        target: "flash_messages",
        partial: "layouts/shared/flash",
        locals: { alert: e.message, notice: nil }
      )

      # ERROR 2: Broadcast an 'Error Signal' to stop the spinner
      # We send empty text with error: true
      broadcast_result(stream_id, text: "", error: true)
    ensure
      blob&.purge
    end
  end

  private

  def broadcast_result(stream_id, text:, error: false)
    Turbo::StreamsChannel.broadcast_update_to(
      "document_extractions_#{stream_id}",
      target: "extraction_hidden_result",
      partial: "document_extractions/async_result",
      locals: { text: text, error: error }
    )
  end
end
