# coding: utf-8

#
# Interface for the Imgur API
#

module Imgurr
  class ImgurAPI
    class << self
      API_URI = URI.parse('https://api.imgur.com')
      API_PUBLIC_KEY = 'Client-ID 70ff50b8dfc3a53'

      ENDPOINTS = {
        :image   => '/3/image/',
        :gallery => '/3/gallery/'
      }

      # Public: accesses the in-memory JSON representation.
      #
      # Returns a Storage instance.
      def storage
        Boom.storage
      end

      # HTTP Client used for API requests
      # TODO: Confirm SSL Certificate
      def web_client
        http = Net::HTTP.new(API_URI.host, API_URI.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http
      end

      # Public: Upload an image
      #
      # args    - The image path for the image to upload
      # 
      def upload(image_path)
        params   = {:image => File.read(image_path)}
        request  = Net::HTTP::Post.new(API_URI.request_uri + ENDPOINTS[:image])
        request.set_form_data(params)
        request.add_field('Authorization', API_PUBLIC_KEY)

        response = web_client.request(request)
        handle_upload_response(response.body)
      end

      # Public: Get info about an image
      #
      # args    - The image imgur id
      #
      def get_info(image_id)
        request  = Net::HTTP::Get.new(API_URI.request_uri + ENDPOINTS[:image] + image_id)
        request.add_field('Authorization', API_PUBLIC_KEY)

        response = web_client.request(request)
        handle_info_response(response.body)
      end

      # Public: Handle API Response
      #
      # args    - Response data
      # 
      def handle_upload_response(response)
        data = JSON.parse(response)
        puts JSON.pretty_unparse(data) if Imgurr::DEBUG
        if data['success']
          return data['data']['link']
        end
        ImgurErrors.handle_error(response)
      end

      # Public: Handle API Response
      #
      # args    - Response data
      #
      def handle_info_response(response)
        data = JSON.parse(response)
        puts JSON.pretty_unparse(data) if Imgurr::DEBUG
        if data['success']
          return "
            Image ID   : #{data['data']['id']}
            Views      : #{data['data']['views']}
            Bandwidth  : #{Numbers.to_human(data['data']['bandwidth'])}
            Title      : #{data['data']['title']}
            Desc       : #{data['data']['description']}
            Animated   : #{data['data']['animated']}
            Width      : #{data['data']['width']} px
            Height     : #{data['data']['height']} px
            Link       : #{data['data']['link']}
          ".gsub(/^ {8}/, '')
        end
        ImgurErrors.handle_error(response)
      end

    end
  end
end