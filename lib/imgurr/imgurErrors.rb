# coding: utf-8

#
# Interface for the Imgur API
#

module Imgurr
	class ImgurErrors
		class << self

			def handle_error(response)
        data = JSON.parse(response)
        "Imgur Error: #{data['data']['error']} (#{data['status']})"
			end
			
		end
	end
end