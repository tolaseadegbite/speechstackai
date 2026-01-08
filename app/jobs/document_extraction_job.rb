class DocumentExtractionJob < ApplicationJob
  queue_as :text_extraction

  def perform(blob_id, stream_id)
    blob = ActiveStorage::Blob.find(blob_id)
    extracted_text = TextExtractor.extract(blob)

    # Broadcast to the specific stream ID provided by the frontend
    Turbo::StreamsChannel.broadcast_update_to(
      "document_extractions_#{stream_id}",
      target: "extraction_hidden_result", # We update a hidden div
      partial: "document_extractions/async_result",
      locals: { text: extracted_text }
    )
  ensure
    # Clean up the file from storage after processing
    blob&.purge
  end
end
