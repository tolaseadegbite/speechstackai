class DocumentExtractionsController < ApplicationController
  def create
    file = params[:file]
    stream_id = params[:stream_id] # Unique ID from frontend

    if file.present?
      # 1. Upload file to ActiveStorage (so the Job can access it)
      blob = ActiveStorage::Blob.create_and_upload!(
        io: file,
        filename: file.original_filename,
        content_type: file.content_type
      )

      # 2. Enqueue the job
      DocumentExtractionJob.perform_later(blob.id, stream_id)

      # 3. Respond with 200 OK (Frontend shows spinner)
      head :ok
    else
      head :unprocessable_entity
    end
  end
end
