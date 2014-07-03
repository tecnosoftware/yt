require 'spec_helper'
require 'yt/models/account'

describe Yt::Account, :device_app do
  describe '.channel' do
    it { expect($account.channel).to be_a Yt::Channel }
  end

  describe '.user_info' do
    it { expect($account.user_info).to be_a Yt::UserInfo }
  end

  describe '.videos' do
    it { expect($account.videos).to be_a Yt::Collections::Videos }
    it { expect($account.videos.first).to be_a Yt::Video }

    describe '.where(q: query_string)' do
      let(:count) { $account.videos.where(q: query).count }

      context 'given a query string that matches any video owned by the account' do
        let(:query) { ENV['YT_TEST_MATCHING_QUERY_STRING'] }
        it { expect(count).to be > 0 }
      end

      context 'given a query string that does not match any video owned by the account' do
        let(:query) { '--not-a-matching-query-string--' }
        it { expect(count).to be_zero }
      end
    end
  end

  describe '.upload_video' do
    let(:video_params) { {title: 'Test Yt upload', privacy_status: 'private'} }
    let(:video) { $account.upload_video path_or_url, video_params }

    context 'given the path to a local video file' do
      let(:path_or_url) { File.expand_path '../video.mp4', __FILE__ }

      it { expect(video).to be_a Yt::Video }
    end

    context 'given the URL of a remote video file' do
      let(:path_or_url) { 'https://bit.ly/yt_test' }

      it { expect(video).to be_a Yt::Video }
    end
  end
end