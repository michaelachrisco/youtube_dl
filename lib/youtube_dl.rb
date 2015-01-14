require 'rubygems'
require 'httparty'
require 'uri'
require 'cgi'

module YoutubeDl
  class YoutubeVideo
    YOUTUBE_DL = File.join(File.expand_path(File.dirname(__FILE__)), '../bin/youtube-dl')

    FORMATS = { 18 => { ext: 'mp4' } }

    def initialize(page_uri, options = {})
      @uri = URI.parse page_uri
      @location = options[:location] || 'tmp/downloads' # default path
      @format = options[:format] || 18                  # default format
      @no_ssl = options[:no_ssl]                        # default ssl
      @youtube_dl_binary = options[:youtube_dl_binary] || YOUTUBE_DL
    end

    attr_reader :youtube_dl_binary

    def video_id
      params(@uri.query)['v'].first
    end

    def title
      extended_info_body['title'].first if extended_info.code == 200
    end

    def get_url
      `#{youtube_dl_binary} -g #{@uri.to_s} -f #{@format} #{@no_ssl ? '--prefer-insecure' : ''}`.strip
    end

    def get_json
      `#{youtube_dl_binary} -j #{@uri.to_s} #{@no_ssl ? '--prefer-insecure' : ''}`.strip
    end

    def extended_info
      @video_info ||= HTTParty.get("http://www.youtube.com/get_video_info?video_id=#{video_id}&el=detailpage")
    end

    def download_video(options = {})
      system(youtube_dl_binary, '-q', '--no-progress', '-o',
             video_filename, '-f',
             (options[:format] || @format).to_s, @uri.to_s)
      video_filename if File.exist?(video_filename)
    end

    def download_audio(options = {})
      system(youtube_dl_binary, '--extract-audio', '--no-mtime', '-q',
             '--no-progress', '-o', video_filename, '-f',
             (options[:format] || @format).to_s, @uri.to_s)
      video_filename if File.exist?(video_filename)
    end

    def download_preview(_options = {})
      link = if !extended_info_body['iurlsd'].blank?
               extended_info_body['iurlsd'].first
             else
               extended_info_body['thumbnail_url'].first
      end
      system('wget', '-O', preview_filename, link)
      preview_filename if File.exist?(preview_filename)
    end

    def preview_filename
      File.join(@location, "#{video_id}.jpg")
    end

    def video_filename
      File.join(@location, "#{video_id}.#{FORMATS[@format][:ext]}")
    end

    def extended_info_body
      params(extended_info.body)
    end

    def use_batch_file(batch_file)
      system(youtube_dl_binary, '-a', batch_file)
    end

    private

    def params(body)
      CGI.parse(body)
    end
  end
end
