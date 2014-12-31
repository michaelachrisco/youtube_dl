require 'spec_helper'
require File.join(File.expand_path(File.dirname(__FILE__)), '/../../lib/youtube_dl')

RSpec.describe YoutubeDl::YoutubeVideo do
  describe '#initialize' do
    context 'with empty video' do
      subject(:video) { YoutubeDl::YoutubeVideo.new('') }

      it { is_expected.to be_truthy }
    end
  end
  describe 'With video' do
    VCR.use_cassette('video') do
      let(:exe_path) {
        File.join(File.expand_path(File.dirname(__FILE__)),
                  '/../../bin/youtube-dl -s')
      }

      subject(:video) {
        YoutubeDl::YoutubeVideo.new('http://www.youtube.com/watch?v=zzG4K2m_j5U',
                                    youtube_dl_binary: exe_path)
      }

      it { is_expected.to be_truthy }
      
      describe '.video_id' do
        it { expect(video.video_id).to eq('zzG4K2m_j5U') }
      end
      
      describe '.title' do
        it { expect(video.title).to eq('Master and Commander Trailer') }
      end
      
      # TODO: Make pass
      # describe '.get_url' do
      #   it {expect(video.get_url).to eq('http://www.youtube.com/watch?v=zzG4K2m_j5U')}
      # end
      
      # TODO: Add all json keys
      describe '.get_json' do
        subject(:json) { video.get_json }
        it { is_expected.to be_truthy }
      end
      
      # TODO: Add all info
      describe '.extended_info' do
        it { expect(video.extended_info).to be_truthy }
      end
      
      #TODO:
      describe '.download_video' do
        # it {
        #   expect(video.download_video)
        #     .to eq('tmp/downloads/zzG4K2m_j5U.mp4')
        # }
      end

      describe '.download_audio' do
        #   it {
        #     expect(video.download_audio)
        #     .to eq('tmp/downloads/zzG4K2m_j5U.mp4')
        #   }
      end
      
      # TODO: test for other video urls
      describe '.download_preview' do
        # it {
        #   expect(video.download_preview)
        #   .to eq('tmp/downloads/zzG4K2m_j5U.mp4')
        # }
      end

      describe '.preview_filename' do
      it   {
        expect(video.preview_filename  )
        .to eq('tmp/downloads/zzG4K2m_j5U.jpg'  )
        }
    end
      describe '.video_filename' do
        it {
          expect(video.video_filename)
          .to eq('tmp/downloads/zzG4K2m_j5U.mp4')
        }
      end
    end
  end
end

