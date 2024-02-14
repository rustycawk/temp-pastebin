require "http/server"
require "random"

module Temp::Pastebin
  VERSION = "0.1.0"

  def self.generate_alphanumeric(length : Int32) : String
    charset = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    Array.new(length) { charset.sample }.join
  end

  if !File.directory?("storage")
    Dir.mkdir("storage")
  end

  server = HTTP::Server.new do |context|
    if context.request.method == "POST"
      body = context.request.body.not_nil!.gets_to_end

      random_filename = generate_alphanumeric(10)

      File.write("storage/#{random_filename}", body)

      context.response.content_type = "text/plain"
      context.response.print("https://paste.5dev.kz/#{random_filename}")
    else
      filename = context.request.path.split("/").last

      if filename == ""
        context.response.status_code = 404
        next
      end

      if File.exists?("storage/#{filename}")
        context.response.content_type = "text/plain"
        context.response.print(File.read("storage/#{filename}"))
      else
        context.response.status_code = 404
      end
    end
  end

  server.bind_tcp("0.0.0.0", 7487)
  puts "Server listening on http://0.0.0.0:7487"
  server.listen
end
