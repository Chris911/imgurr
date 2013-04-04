# coding: utf-8

#
# Interface for the Imgur API
#

module Imgurup
	class ImgurAPI
		class << self
			API_URI = URI.parse("https://api.imgur.com")

			ENDPOINTS = {
				:image   => "/3/image",
				:gallery => "/3/gallery"
			}

			httpClient = Net::HTTP.new(API_URL)

			def upload(image_path)
				params   = {image => File.open(image_data)}
				response = httpClient.post_form(API_URI, params)
			end

			def handle_response(response)
				
			end
		end
	end
end