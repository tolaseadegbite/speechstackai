require "net/http"
require "uri"
require "json"

class ModalApiClient
  # Custom error class
  class RequestError < StandardError; end

  REQUEST_TIMEOUT = 300

  def initialize
    @api_key = Rails.application.credentials.modal.api_key
    @api_secret = Rails.application.credentials.modal.api_secret
    @endpoint = Rails.application.credentials.modal.generate
  end

  def generate(text:, voice_name:)
    uri = URI.parse(@endpoint)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # --- FIX START ---
    # In development, bypass strict SSL checks to avoid "unable to get certificate CRL" errors.
    # In production, this block is skipped, keeping it secure.
    if Rails.env.development?
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    # --- FIX END ---

    http.open_timeout = 10
    http.read_timeout = REQUEST_TIMEOUT

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request["Modal-Key"] = @api_key
    request["Modal-Secret"] = @api_secret

    request.body = { text: text, voice: voice_name }.to_json

    response = http.request(request)

    handle_response(response)
  end

  private

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      JSON.parse(response.body).deep_symbolize_keys
    else
      raise RequestError, "Modal API Error (#{response.code}): #{response.body}"
    end
  rescue JSON::ParserError
    raise RequestError, "Invalid JSON response from Modal"
  end
end
