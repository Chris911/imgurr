# coding: utf-8

#
# Interface for the Imgur API
#

module Imgurup
  class ImgurAPI
    class << self
      API_URI = URI.parse('https://api.imgur.com')
      API_PUBLIC_KEY = 'Client-ID 70ff50b8dfc3a53'

      ENDPOINTS = {
        :image   => '/3/image',
        :gallery => '/3/gallery'
      }

      # HTTP Client used for API requests
      # TODO: Confirm SSL Certificate
      @@http = Net::HTTP.new(API_URI.host, API_URI.port)
      @@http.use_ssl = true
      @@http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # Public: Upload an image
      #
      # args    - The image path for the image to upload
      # 
      def upload(image_path)
        params   = {'image' => File.read(image_path)}
        request  = Net::HTTP::Post.new(API_URI.request_uri + ENDPOINTS[:image])
        request.set_form_data(params)
        request.add_field('Authorization', API_PUBLIC_KEY)

        response = @@http.request(request)
        handle_response(response.body)
      end

      # Public: Handle API Response
      #
      # args    - Response data
      # 
      def handle_response(response)
        data = JSON.parse(response)
        #puts JSON.pretty_unparse(data)
        return data['data']['link'] if(data['success'])
      end

    end
  end
end