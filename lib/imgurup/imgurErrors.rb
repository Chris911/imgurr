# coding: utf-8

#
# Interface for the Imgur API
#

module Imgurup
	class ImgurErrors
		class << self

			ERROR_CODES = {
				400 => 'Missing Parameters',
				401 => 'Auth Required',
				403 => 'Forbidden',
				404 => 'Resource does not exist',
				429 => 'Rate Limiting',
				500 => 'Internal Error'
			}

			def handle_error(response)
				
			end
			
		end
	end
end