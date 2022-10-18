require "uri"
require "net/http"
require "openssl"
require "json"


def main(req, res)
  fileUrl = nil
  begin
    payload = JSON.parse(req.payload)
    fileUrl = payload["fileUrl"]
  rescue Exception => err
      puts err
      raise "Payload is invalid."
  end
  url = URI("https://api.deepgram.com/v1/listen?detect_language=true&punctuate=true")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(url)
  request["content-type"] = "application/json"
  request["Authorization"] = "Token #{req.env["DEEPGRAM_API_KEY"]}"
  request.body = "{\"url\":\"#{fileUrl}\"}"
  begin
    response = http.request(request)
  rescue Exception => err
    res.json({
      success: false,
      deepgramData: "Please provide a valid file URL."
    })
  end
  parsed_response = JSON.parse(response.read_body)
  detected_language = parsed_response["results"]["channels"][0]["detected_language"]
  res.json({
    success: true,
    deepgramData: detected_language
  })
end
