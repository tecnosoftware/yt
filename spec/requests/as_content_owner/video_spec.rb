# encoding: UTF-8
require 'spec_helper'
require 'yt/models/video'

describe Yt::Video, :partner do
  subject(:video) { Yt::Video.new id: id, auth: $content_owner }

  context 'given a video of a partnered channel', :partner do
    context 'managed by the authenticated Content Owner' do
      let(:id) { ENV['YT_TEST_PARTNER_VIDEO_ID'] }

      describe 'advertising options can be retrieved' do
        it { expect{video.advertising_options_set}.not_to raise_error }
      end

      describe 'earnings can be retrieved for a specific day' do
        context 'in which the video made any money' do
          let(:earnings) {video.earnings_on ENV['YT_TEST_PARTNER_VIDEO_DATE']}
          it { expect(earnings).to be_a Float }
        end

        context 'in the future' do
          let(:earnings) { video.earnings_on 5.days.from_now}
          it { expect(earnings).to be_nil }
        end
      end

      describe 'earnings can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:earnings) { video.earnings since: date, by: by, in: location }
        let(:date) { 4.days.ago }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(earnings.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(earnings.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(earnings.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(earnings.keys).to eq [country_code] }
          end
        end
      end

      describe 'earnings can be retrieved for a range of days' do
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        specify 'with a given start and end (:since / :until option)' do
          expect(video.earnings(since: date, until: date).keys.min).to eq date.to_date
        end

        specify 'with a given start and end (:from / :to option)' do
          expect(video.earnings(from: date, to: date).keys.min).to eq date.to_date
        end
      end

      describe 'earnings can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }
        let(:keys) { range.values }

        specify 'with the :by option set to :range' do
          earnings = video.earnings range.merge by: :range
          expect(earnings.size).to be 1
          expect(earnings[:total]).to be_a Float
        end
      end

      describe 'earnings can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          earnings = video.earnings range
          expect(earnings.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          earnings = video.earnings range.merge by: :day
          expect(earnings.keys).to eq range.values
        end
      end

      describe 'earnings can be grouped by country' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :country' do
          earnings = video.earnings range.merge by: :country
          expect(earnings.keys).to all(be_a String)
          expect(earnings.keys.map(&:length).uniq).to eq [2]
          expect(earnings.values).to all(be_a Float)
        end
      end

      describe 'views can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:views) { video.views_on 5.days.ago}
          it { expect(views).to be_an Integer }
        end

        context 'in which the video was not partnered' do
          let(:views) { video.views_on 20.years.ago}
          it { expect(views).to be_nil }
        end
      end

      describe 'views can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:views) { video.views since: date, by: by, in: location }
        let(:date) { 4.days.ago }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(views.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(views.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(views.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(views.keys).to eq [country_code] }
          end
        end

        context 'and grouped by state' do
          let(:by) { :state }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(views.keys.map(&:length).uniq).to eq [2] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(views.keys.map(&:length).uniq).to eq [2] }
          end
        end
      end

      describe 'views can be retrieved for a single US state' do
        let(:state_code) { 'NY' }
        let(:views) { video.views since: date, by: by, in: location }
        let(:date) { 4.days.ago }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(views.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(views.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by US state' do
          let(:by) { :state }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(views.keys).to eq [state_code] }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(views.keys).to eq [state_code] }
          end
        end
      end

      describe 'views can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.views(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.views(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.views(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.views(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'views can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          views = video.views range.merge by: :range
          expect(views.size).to be 1
          expect(views[:total]).to be_an Integer
        end
      end

      describe 'views can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          views = video.views range
          expect(views.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          views = video.views range.merge by: :day
          expect(views.keys).to eq range.values
        end
      end

      describe 'views can be grouped by traffic source' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }
        let(:keys) { Yt::Collections::Reports::TRAFFIC_SOURCES.keys }

        specify 'with the :by option set to :traffic_source' do
          views = video.views range.merge by: :traffic_source
          expect(views.keys - keys).to be_empty
        end
      end

      describe 'views can be grouped by playback location' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }
        let(:keys) { Yt::Collections::Reports::PLAYBACK_LOCATIONS.keys }

        specify 'with the :by option set to :playback_location' do
          views = video.views range.merge by: :playback_location
          expect(views.keys - keys).to be_empty
        end
      end

      describe 'views can be grouped by embedded player location' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :embedded_player_location' do
          views = video.views range.merge by: :embedded_player_location
          expect(views).not_to be_empty
        end
      end

      describe 'views can be grouped by related video' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :related_video' do
          views = video.views range.merge by: :related_video
          expect(views.keys).to all(be_instance_of Yt::Video)
        end
      end

      describe 'views can be grouped by search term' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :search_term' do
          views = video.views range.merge by: :search_term
          expect(views.keys).to all(be_a String)
        end
      end

      describe 'views can be grouped by device type' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :device_type' do
          views = video.views range.merge by: :device_type
          expect(views.keys).to all(be_instance_of Symbol)
          expect(views.values).to all(be_an Integer)
        end
      end

      describe 'views can be grouped by country' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :country' do
          views = video.views range.merge by: :country
          expect(views.keys).to all(be_a String)
          expect(views.keys.map(&:length).uniq).to eq [2]
          expect(views.values).to all(be_an Integer)
        end
      end

      describe 'views can be grouped by state' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :state' do
          views = video.views range.merge by: :state
          expect(views.keys).to all(be_a String)
          expect(views.keys.map(&:length).uniq).to eq [2]
          expect(views.values).to all(be_an Integer)
        end
      end

      describe 'uniques can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:uniques) { video.uniques since: date, by: by, in: location }
        let(:date) { 4.days.ago }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(uniques.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(uniques.keys.min).to eq date.to_date }
          end
        end
      end

      describe 'uniques can be retrieved for a single US state' do
        let(:state_code) { 'NY' }
        let(:result) { video.uniques since: date, by: by, in: location }
        let(:date) { 4.days.ago }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(result.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(result.keys.min).to eq date.to_date }
          end
        end
      end

      describe 'uniques can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.uniques(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.uniques(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.uniques(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.uniques(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'uniques can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          uniques = video.uniques range
          expect(uniques.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          uniques = video.uniques range.merge by: :day
          expect(uniques.keys).to eq range.values
        end
      end

      describe 'comments can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:comments) { video.comments_on ENV['YT_TEST_PARTNER_VIDEO_DATE']}
          it { expect(comments).to be_an Integer }
        end

        context 'in which the video was not partnered' do
          let(:comments) { video.comments_on 20.years.ago}
          it { expect(comments).to be_nil }
        end
      end


      describe 'comments can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:comments) { video.comments since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(comments.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(comments.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(comments.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(comments.keys).to eq [country_code] }
          end
        end
      end

      describe 'comments can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.comments(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.comments(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.comments(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.comments(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'comments can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          comments = video.comments range.merge by: :range
          expect(comments.size).to be 1
          expect(comments[:total]).to be_an Integer
        end
      end

      describe 'comments can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          comments = video.comments range
          expect(comments.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          comments = video.comments range.merge by: :day
          expect(comments.keys).to eq range.values
        end
      end

      describe 'comments can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          comments = video.comments range.merge by: :country
          expect(comments.keys).to all(be_a String)
          expect(comments.keys.map(&:length).uniq).to eq [2]
          expect(comments.values).to all(be_an Integer)
        end
      end

      describe 'likes can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:likes) { video.likes_on ENV['YT_TEST_PARTNER_VIDEO_DATE']}
          it { expect(likes).to be_an Integer }
        end

        context 'in which the video was not partnered' do
          let(:likes) { video.likes_on 20.years.ago}
          it { expect(likes).to be_nil }
        end
      end

      describe 'likes can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:likes) { video.likes since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(likes.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(likes.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(likes.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(likes.keys).to eq [country_code] }
          end
        end
      end

      describe 'likes can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.likes(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.likes(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.likes(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.likes(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'likes can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          likes = video.likes range.merge by: :range
          expect(likes.size).to be 1
          expect(likes[:total]).to be_an Integer
        end
      end

      describe 'likes can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          likes = video.likes range
          expect(likes.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          likes = video.likes range.merge by: :day
          expect(likes.keys).to eq range.values
        end
      end

      describe 'likes can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          likes = video.likes range.merge by: :country
          expect(likes.keys).to all(be_a String)
          expect(likes.keys.map(&:length).uniq).to eq [2]
          expect(likes.values).to all(be_an Integer)
        end
      end

      describe 'dislikes can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:dislikes) { video.dislikes_on ENV['YT_TEST_PARTNER_VIDEO_DATE']}
          it { expect(dislikes).to be_an Integer }
        end

        context 'in which the video was not partnered' do
          let(:dislikes) { video.dislikes_on 20.years.ago}
          it { expect(dislikes).to be_nil }
        end
      end

      describe 'dislikes can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:dislikes) { video.dislikes since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(dislikes.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(dislikes.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(dislikes.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(dislikes.keys).to eq [country_code] }
          end
        end
      end

      describe 'dislikes can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.dislikes(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.dislikes(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.dislikes(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.dislikes(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'dislikes can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          dislikes = video.dislikes range.merge by: :range
          expect(dislikes.size).to be 1
          expect(dislikes[:total]).to be_an Integer
        end
      end

      describe 'dislikes can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          dislikes = video.dislikes range
          expect(dislikes.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          dislikes = video.dislikes range.merge by: :day
          expect(dislikes.keys).to eq range.values
        end
      end

      describe 'dislikes can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          dislikes = video.dislikes range.merge by: :country
          expect(dislikes.keys).to all(be_a String)
          expect(dislikes.keys.map(&:length).uniq).to eq [2]
          expect(dislikes.values).to all(be_an Integer)
        end
      end

      describe 'shares can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:date) { Date.parse(ENV['YT_TEST_PARTNER_VIDEO_DATE']) + 95 }
          let(:shares) { video.shares_on date }
          it { expect(shares).to be_an Integer }
        end

        context 'in which the video was not partnered' do
          let(:shares) { video.shares_on 20.years.ago}
          it { expect(shares).to be_nil }
        end
      end

      describe 'shares can be retrieved for a single country' do
        let(:country_code) { 'PT' }
        let(:shares) { video.shares since: date, by: by, in: location }
        let(:date) { Date.parse(ENV['YT_TEST_PARTNER_VIDEO_DATE']) + 95 }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(shares.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(shares.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(shares.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(shares.keys).to eq [country_code] }
          end
        end
      end

      describe 'shares can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.shares(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.shares(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.shares(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.shares(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'shares can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          shares = video.shares range.merge by: :range
          expect(shares.size).to be 1
          expect(shares[:total]).to be_an Integer
        end
      end

      describe 'shares can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          shares = video.shares range
          expect(shares.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          shares = video.shares range.merge by: :day
          expect(shares.keys).to eq range.values
        end
      end

      describe 'shares can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          shares = video.shares range.merge by: :country
          expect(shares.keys).to all(be_a String)
          expect(shares.keys.map(&:length).uniq).to eq [2]
          expect(shares.values).to all(be_an Integer)
        end
      end

      describe 'gained subscribers can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:subscribers_gained) { video.subscribers_gained_on ENV['YT_TEST_PARTNER_VIDEO_DATE']}
          it { expect(subscribers_gained).to be_an Integer }
        end

        context 'in which the video was not partnered' do
          let(:subscribers_gained) { video.subscribers_gained_on 20.years.ago}
          it { expect(subscribers_gained).to be_nil }
        end
      end

      describe 'gained subscribers can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:subscribers_gained) { video.subscribers_gained since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(subscribers_gained.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(subscribers_gained.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(subscribers_gained.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(subscribers_gained.keys).to eq [country_code] }
          end
        end
      end

      describe 'gained subscribers can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.subscribers_gained(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.subscribers_gained(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.subscribers_gained(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.subscribers_gained(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'gained subscribers can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          subscribers_gained = video.subscribers_gained range.merge by: :range
          expect(subscribers_gained.size).to be 1
          expect(subscribers_gained[:total]).to be_an Integer
        end
      end

      describe 'gained subscribers can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          subscribers_gained = video.subscribers_gained range
          expect(subscribers_gained.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          subscribers_gained = video.subscribers_gained range.merge by: :day
          expect(subscribers_gained.keys).to eq range.values
        end
      end

      describe 'gained subscribers can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          subscribers_gained = video.subscribers_gained range.merge by: :country
          expect(subscribers_gained.keys).to all(be_a String)
          expect(subscribers_gained.keys.map(&:length).uniq).to eq [2]
          expect(subscribers_gained.values).to all(be_an Integer)
        end
      end

      describe 'lost subscribers can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:subscribers_lost) { video.subscribers_lost_on ENV['YT_TEST_PARTNER_VIDEO_DATE']}
          it { expect(subscribers_lost).to be_an Integer }
        end

        context 'in which the video was not partnered' do
          let(:subscribers_lost) { video.subscribers_lost_on 20.years.ago}
          it { expect(subscribers_lost).to be_nil }
        end
      end

      describe 'lost subscribers can be retrieved for a single country' do
        let(:country_code) { 'BR' }
        let(:subscribers_lost) { video.subscribers_lost since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(subscribers_lost.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(subscribers_lost.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(subscribers_lost.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(subscribers_lost.keys).to eq [country_code] }
          end
        end
      end

      describe 'lost subscribers can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.subscribers_lost(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.subscribers_lost(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.subscribers_lost(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.subscribers_lost(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'lost subscribers can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          subscribers_lost = video.subscribers_lost range.merge by: :range
          expect(subscribers_lost.size).to be 1
          expect(subscribers_lost[:total]).to be_an Integer
        end
      end

      describe 'lost subscribers can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          subscribers_lost = video.subscribers_lost range
          expect(subscribers_lost.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          subscribers_lost = video.subscribers_lost range.merge by: :day
          expect(subscribers_lost.keys).to eq range.values
        end
      end

      describe 'lost subscribers can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          subscribers_lost = video.subscribers_lost range.merge by: :country
          expect(subscribers_lost.keys).to all(be_a String)
          expect(subscribers_lost.keys.map(&:length).uniq).to eq [2]
          expect(subscribers_lost.values).to all(be_an Integer)
        end
      end

      describe 'added favorites can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:favorites_added) { video.favorites_added_on ENV['YT_TEST_PARTNER_VIDEO_DATE']}
          it { expect(favorites_added).to be_an Integer }
        end

        context 'in which the video was not partnered' do
          let(:favorites_added) { video.favorites_added_on 20.years.ago}
          it { expect(favorites_added).to be_nil }
        end
      end

      describe 'favorites added can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:favorites_added) { video.favorites_added since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(favorites_added.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(favorites_added.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(favorites_added.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(favorites_added.keys).to eq [country_code] }
          end
        end
      end

      describe 'added favorites can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.favorites_added(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.favorites_added(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.favorites_added(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.favorites_added(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'added favorites can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          favorites_added = video.favorites_added range.merge by: :range
          expect(favorites_added.size).to be 1
          expect(favorites_added[:total]).to be_an Integer
        end
      end

      describe 'added favorites can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          favorites_added = video.favorites_added range
          expect(favorites_added.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          favorites_added = video.favorites_added range.merge by: :day
          expect(favorites_added.keys).to eq range.values
        end
      end

      describe 'added favorites can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          favorites_added = video.favorites_added range.merge by: :country
          expect(favorites_added.keys).to all(be_a String)
          expect(favorites_added.keys.map(&:length).uniq).to eq [2]
          expect(favorites_added.values).to all(be_an Integer)
        end
      end

      describe 'removed favorites can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:favorites_removed) { video.favorites_removed_on ENV['YT_TEST_PARTNER_VIDEO_DATE']}
          it { expect(favorites_removed).to be_an Integer }
        end

        context 'in which the video was not partnered' do
          let(:favorites_removed) { video.favorites_removed_on 20.years.ago}
          it { expect(favorites_removed).to be_nil }
        end
      end

      describe 'favorites removed can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:favorites_removed) { video.favorites_removed since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(favorites_removed.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(favorites_removed.keys.min).to eq date.to_date }
          end
        end

        # TODO: Remove "removed favorites" since it’s deprecated!
        # context 'and grouped by country' do
        #   let(:by) { :country }
        #
        #   context 'with the :in option set to the country code' do
        #     let(:location) { country_code }
        #     it { expect(favorites_removed.keys).to eq [country_code] }
        #   end
        #
        #   context 'with the :in option set to {country: country code}' do
        #     let(:location) { {country: country_code} }
        #     it { expect(favorites_removed.keys).to eq [country_code] }
        #   end
        # end
      end

      describe 'removed favorites can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.favorites_removed(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.favorites_removed(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.favorites_removed(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.favorites_removed(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'removed favorites can be grouped by range' do
        let(:id) { 'NeMlqbX2Ifg' }
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          favorites_removed = video.favorites_removed range.merge by: :range
          expect(favorites_removed.size).to be 1
          expect(favorites_removed[:total]).to be_an Integer
        end
      end

      describe 'removed favorites can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          favorites_removed = video.favorites_removed range
          expect(favorites_removed.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          favorites_removed = video.favorites_removed range.merge by: :day
          expect(favorites_removed.keys).to eq range.values
        end
      end

      # TODO: Remove "removed favorites" since it’s deprecated!
      # describe 'removed favorites can be grouped by country' do
      #   let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }
      #
      #   specify 'with the :by option set to :country' do
      #     favorites_removed = video.favorites_removed range.merge by: :country
      #     expect(favorites_removed.keys).to all(be_a String)
      #     expect(favorites_removed.keys.map(&:length).uniq).to eq [2]
      #     expect(favorites_removed.values).to all(be_an Integer)
      #   end
      # end

      describe 'estimated minutes watched can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:estimated_minutes_watched) { video.estimated_minutes_watched_on 5.days.ago}
          it { expect(estimated_minutes_watched).to be_a Float }
        end

        context 'in which the video was not partnered' do
          let(:estimated_minutes_watched) { video.estimated_minutes_watched_on 20.years.ago}
          it { expect(estimated_minutes_watched).to be_nil }
        end
      end

      describe 'estimated minutes watched can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:estimated_minutes_watched) { video.estimated_minutes_watched since: date, by: by, in: location }
        let(:date) { 4.days.ago }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(estimated_minutes_watched.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(estimated_minutes_watched.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(estimated_minutes_watched.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(estimated_minutes_watched.keys).to eq [country_code] }
          end
        end
      end

      describe 'estimated minutes watched can be retrieved for a single US state' do
        let(:state_code) { 'NY' }
        let(:minutes) { video.estimated_minutes_watched since: date, by: by, in: location }
        let(:date) { 4.days.ago }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(minutes.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(minutes.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by US state' do
          let(:by) { :state }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(minutes.keys).to eq [state_code] }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(minutes.keys).to eq [state_code] }
          end
        end
      end

      describe 'estimated minutes watched can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.estimated_minutes_watched(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.estimated_minutes_watched(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.estimated_minutes_watched(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.estimated_minutes_watched(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'estimated minutes watched can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          minutes = video.estimated_minutes_watched range.merge by: :range
          expect(minutes.size).to be 1
          expect(minutes[:total]).to be_a Float
        end
      end

      describe 'estimated minutes watched can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          estimated_minutes_watched = video.estimated_minutes_watched range
          expect(estimated_minutes_watched.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          estimated_minutes_watched = video.estimated_minutes_watched range.merge by: :day
          expect(estimated_minutes_watched.keys).to eq range.values
        end
      end

      describe 'estimated minutes watched can be grouped by traffic source' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }
        let(:keys) { Yt::Collections::Reports::TRAFFIC_SOURCES.keys }

        specify 'with the :by option set to :traffic_source' do
          estimated_minutes_watched = video.estimated_minutes_watched range.merge by: :traffic_source
          expect(estimated_minutes_watched.keys - keys).to be_empty
        end
      end

      describe 'estimated minutes watched can be grouped by playback location' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }
        let(:keys) { Yt::Collections::Reports::PLAYBACK_LOCATIONS.keys }

        specify 'with the :by option set to :playback_location' do
          estimated_minutes_watched = video.estimated_minutes_watched range.merge by: :playback_location
          expect(estimated_minutes_watched.keys - keys).to be_empty
        end
      end

      describe 'estimated minutes watched can be grouped by embedded player location' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :embedded_player_location' do
          estimated_minutes_watched = video.estimated_minutes_watched range.merge by: :embedded_player_location
          expect(estimated_minutes_watched).not_to be_empty
        end
      end

      describe 'estimated minutes watched can be grouped by related video' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :related_video' do
          estimated_minutes_watched = video.estimated_minutes_watched range.merge by: :related_video
          expect(estimated_minutes_watched.keys).to all(be_instance_of Yt::Video)
        end
      end

      describe 'estimated minutes watched can be grouped by search term' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :search_term' do
          estimated_minutes_watched = video.estimated_minutes_watched range.merge by: :search_term
          expect(estimated_minutes_watched.keys).to all(be_a String)
        end
      end

      describe 'estimated minutes watched can be grouped by device type' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :device_type' do
          estimated_minutes_watched = video.estimated_minutes_watched range.merge by: :device_type
          expect(estimated_minutes_watched.keys).to all(be_instance_of Symbol)
          expect(estimated_minutes_watched.values).to all(be_instance_of Float)
        end
      end

      describe 'estimated minutes watched can be grouped by country' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :country' do
          minutes = video.estimated_minutes_watched range.merge by: :country
          expect(minutes.keys).to all(be_a String)
          expect(minutes.keys.map(&:length).uniq).to eq [2]
          expect(minutes.values).to all(be_a Float)
        end
      end

      describe 'estimated minutes watched can be grouped by state' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :state' do
          minutes = video.estimated_minutes_watched range.merge by: :state
          expect(minutes.keys).to all(be_a String)
          expect(minutes.keys.map(&:length).uniq).to eq [2]
          expect(minutes.values).to all(be_a Float)
        end
      end

      describe 'average view duration can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:average_view_duration) { video.average_view_duration_on 5.days.ago}
          it { expect(average_view_duration).to be_a Float }
        end

        context 'in which the video was not partnered' do
          let(:average_view_duration) { video.average_view_duration_on 20.years.ago}
          it { expect(average_view_duration).to be_nil }
        end
      end

      describe 'average view duration can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:average_view_duration) { video.average_view_duration since: date, by: by, in: location }
        let(:date) { 4.days.ago }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(average_view_duration.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(average_view_duration.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(average_view_duration.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(average_view_duration.keys).to eq [country_code] }
          end
        end
      end

      describe 'average view duration can be retrieved for a single US state' do
        let(:state_code) { 'NY' }
        let(:duration) { video.average_view_duration since: date, by: by, in: location }
        let(:date) { 4.days.ago }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(duration.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(duration.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by US state' do
          let(:by) { :state }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(duration.keys).to eq [state_code] }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(duration.keys).to eq [state_code] }
          end
        end
      end

      describe 'average view duration can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.average_view_duration(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.average_view_duration(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.average_view_duration(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.average_view_duration(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'average view duration can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          duration = video.average_view_duration range.merge by: :range
          expect(duration.size).to be 1
          expect(duration[:total]).to be_a Float
        end
      end

      describe 'average view duration can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          average_view_duration = video.average_view_duration range
          expect(average_view_duration.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          average_view_duration = video.average_view_duration range.merge by: :day
          expect(average_view_duration.keys).to eq range.values
        end
      end

      describe 'average view duration can be grouped by country' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :country' do
          duration = video.average_view_duration range.merge by: :country
          expect(duration.keys).to all(be_a String)
          expect(duration.keys.map(&:length).uniq).to eq [2]
          expect(duration.values).to all(be_a Float)
        end
      end

      describe 'average view duration can be grouped by state' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :state' do
          duration = video.average_view_duration range.merge by: :state
          expect(duration.keys).to all(be_a String)
          expect(duration.keys.map(&:length).uniq).to eq [2]
          expect(duration.values).to all(be_a Float)
        end
      end

      describe 'average view percentage can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:average_view_percentage) { video.average_view_percentage_on 5.days.ago}
          it { expect(average_view_percentage).to be_a Float }
        end

        context 'in which the video was not partnered' do
          let(:average_view_percentage) { video.average_view_percentage_on 20.years.ago}
          it { expect(average_view_percentage).to be_nil }
        end
      end

      describe 'average view percentage can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:average_view_percentage) { video.average_view_percentage since: date, by: by, in: location }
        let(:date) { 4.days.ago }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(average_view_percentage.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(average_view_percentage.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(average_view_percentage.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(average_view_percentage.keys).to eq [country_code] }
          end
        end
      end

      describe 'average view percentage can be retrieved for a single US state' do
        let(:state_code) { 'NY' }
        let(:percentage) { video.average_view_percentage since: date, by: by, in: location }
        let(:date) { 4.days.ago }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(percentage.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(percentage.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by US state' do
          let(:by) { :state }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(percentage.keys).to eq [state_code] }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(percentage.keys).to eq [state_code] }
          end
        end
      end

      describe 'average view percentage can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.average_view_percentage(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.average_view_percentage(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.average_view_percentage(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.average_view_percentage(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'average view percentage can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          percentage = video.average_view_percentage range.merge by: :range
          expect(percentage.size).to be 1
          expect(percentage[:total]).to be_a Float
        end
      end

      describe 'average view percentage can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          average_view_percentage = video.average_view_percentage range
          expect(average_view_percentage.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          average_view_percentage = video.average_view_percentage range.merge by: :day
          expect(average_view_percentage.keys).to eq range.values
        end
      end

      describe 'average view percentage can be grouped by country' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :country' do
          percentage = video.average_view_percentage range.merge by: :country
          expect(percentage.keys).to all(be_a String)
          expect(percentage.keys.map(&:length).uniq).to eq [2]
          expect(percentage.values).to all(be_a Float)
        end
      end

      describe 'average view percentage can be grouped by state' do
        let(:range) { {since: 4.days.ago, until: 3.days.ago} }

        specify 'with the :by option set to :state' do
          percentage = video.average_view_percentage range.merge by: :state
          expect(percentage.keys).to all(be_a String)
          expect(percentage.keys.map(&:length).uniq).to eq [2]
          expect(percentage.values).to all(be_a Float)
        end
      end

      describe 'impressions can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:impressions) { video.impressions_on ENV['YT_TEST_PARTNER_VIDEO_DATE']}
          it { expect(impressions).to be_an Integer }
        end

        context 'in which the video was not partnered' do
          let(:impressions) { video.impressions_on 20.years.ago}
          it { expect(impressions).to be_nil }
        end
      end

      describe 'impressions can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:impressions) { video.impressions since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(impressions.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(impressions.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(impressions.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(impressions.keys).to eq [country_code] }
          end
        end
      end

      describe 'impressions can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.impressions(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.impressions(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.impressions(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.impressions(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'impressions can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          impressions = video.impressions range.merge by: :range
          expect(impressions.size).to be 1
          expect(impressions[:total]).to be_an Integer
        end
      end

      describe 'impressions can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          impressions = video.impressions range
          expect(impressions.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          impressions = video.impressions range.merge by: :day
          expect(impressions.keys).to eq range.values
        end
      end

      describe 'impressions can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          impressions = video.impressions range.merge by: :country
          expect(impressions.keys).to all(be_a String)
          expect(impressions.keys.map(&:length).uniq).to eq [2]
          expect(impressions.values).to all(be_an Integer)
        end
      end

      describe 'monetized playbacks can be retrieved for a specific day' do
        context 'in which the video was partnered' do
          let(:monetized_playbacks) { video.monetized_playbacks_on ENV['YT_TEST_PARTNER_VIDEO_DATE']}
          it { expect(monetized_playbacks).to be_an Integer }
        end

        context 'in which the video was not partnered' do
          let(:monetized_playbacks) { video.monetized_playbacks_on 20.years.ago}
          it { expect(monetized_playbacks).to be_nil }
        end
      end

      describe 'monetized playbacks can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:monetized_playbacks) { video.monetized_playbacks since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(monetized_playbacks.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(monetized_playbacks.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(monetized_playbacks.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(monetized_playbacks.keys).to eq [country_code] }
          end
        end
      end

      describe 'monetized playbacks can be retrieved for a range of days' do
        let(:date) { 4.days.ago }

        specify 'with a given start (:since option)' do
          expect(video.monetized_playbacks(since: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:until option)' do
          expect(video.monetized_playbacks(until: date).keys.max).to eq date.to_date
        end

        specify 'with a given start (:from option)' do
          expect(video.monetized_playbacks(from: date).keys.min).to eq date.to_date
        end

        specify 'with a given end (:to option)' do
          expect(video.monetized_playbacks(to: date).keys.max).to eq date.to_date
        end
      end

      describe 'monetized playbacks can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          monetized_playbacks = video.monetized_playbacks range.merge by: :range
          expect(monetized_playbacks.size).to be 1
          expect(monetized_playbacks[:total]).to be_an Integer
        end
      end

      describe 'monetized_playbacks can be grouped by day' do
        let(:range) { {since: 4.days.ago.to_date, until: 3.days.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          monetized_playbacks = video.monetized_playbacks range
          expect(monetized_playbacks.keys).to eq range.values
        end

        specify 'with the :by option set to :day' do
          monetized_playbacks = video.monetized_playbacks range.merge by: :day
          expect(monetized_playbacks.keys).to eq range.values
        end
      end

      describe 'monetized playbacks can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          playbacks = video.monetized_playbacks range.merge by: :country
          expect(playbacks.keys).to all(be_a String)
          expect(playbacks.keys.map(&:length).uniq).to eq [2]
          expect(playbacks.values).to all(be_an Integer)
        end
      end

      describe 'annotation clicks can be retrieved for a range of days' do
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }
        let(:date_to) { Date.parse(ENV['YT_TEST_PARTNER_VIDEO_DATE']) + 5 }

        specify 'with a given start (:since option) and a given end (:until option)' do
          expect(video.annotation_clicks(since: date, until: date_to).keys.min).to eq date.to_date
        end

        specify 'with a given start (:from option) and a given end (:to option)' do
          expect(video.annotation_clicks(from: date, to: date_to).keys.min).to eq date.to_date
        end
      end

      describe 'annotation clicks can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:annotation_clicks) { video.annotation_clicks since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(annotation_clicks.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(annotation_clicks.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(annotation_clicks.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(annotation_clicks.keys).to eq [country_code] }
          end
        end

        context 'and grouped by state' do
          let(:by) { :state }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(annotation_clicks.keys.map(&:length).uniq).to eq [2] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(annotation_clicks.keys.map(&:length).uniq).to eq [2] }
          end
        end
      end

      describe 'annotation clicks can be retrieved for a single US state' do
        let(:state_code) { 'CA' }
        let(:clicks) { video.annotation_clicks since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(clicks.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(clicks.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by US state' do
          let(:by) { :state }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(clicks.keys).to eq [state_code] }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(clicks.keys).to eq [state_code] }
          end
        end
      end

      describe 'annotation clicks can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          annotation_clicks = video.annotation_clicks range.merge by: :range
          expect(annotation_clicks.size).to be 1
          expect(annotation_clicks[:total]).to be_an Integer
        end
      end

      describe 'annotation clicks can be grouped by day' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE'], until: Date.parse(ENV['YT_TEST_PARTNER_VIDEO_DATE']) + 5} }

        specify 'without a :by option (default)' do
          annotation_clicks = video.annotation_clicks range
          expect(annotation_clicks.values).to all(be_an Integer)
        end

        specify 'with the :by option set to :day' do
          annotation_clicks = video.annotation_clicks range.merge by: :day
          expect(annotation_clicks.values).to all(be_an Integer)
        end
      end

      describe 'annotation clicks can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          clicks = video.annotation_clicks range.merge by: :country
          expect(clicks.keys).to all(be_a String)
          expect(clicks.keys.map(&:length).uniq).to eq [2]
          expect(clicks.values).to all(be_an Integer)
        end
      end

      describe 'annotation clicks can be grouped by state' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :state' do
          clicks = video.annotation_clicks range.merge by: :state
          expect(clicks.keys).to all(be_a String)
          expect(clicks.keys.map(&:length).uniq).to eq [2]
          expect(clicks.values).to all(be_an Integer)
        end
      end

      describe 'annotation click-through rate can be retrieved for a range of days' do
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }
        let(:date_to) { Date.parse(ENV['YT_TEST_PARTNER_VIDEO_DATE']) + 5 }

        specify 'with a given start (:since option) and a given end (:until option)' do
          expect(video.annotation_click_through_rate(since: date, until: date_to).keys.min).to eq date.to_date
        end

        specify 'with a given start (:from option) and a given end (:to option)' do
          expect(video.annotation_click_through_rate(from: date, to: date_to).keys.min).to eq date.to_date
        end
      end

      describe 'annotation click_through_rate can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:annotation_click_through_rate) { video.annotation_click_through_rate since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(annotation_click_through_rate.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(annotation_click_through_rate.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(annotation_click_through_rate.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(annotation_click_through_rate.keys).to eq [country_code] }
          end
        end

        context 'and grouped by state' do
          let(:by) { :state }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(annotation_click_through_rate.keys.map(&:length).uniq).to eq [2] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(annotation_click_through_rate.keys.map(&:length).uniq).to eq [2] }
          end
        end
      end

      describe 'annotation click_through_rate can be retrieved for a single US state' do
        let(:state_code) { 'CA' }
        let(:click_through_rate) { video.annotation_click_through_rate since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(click_through_rate.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(click_through_rate.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by US state' do
          let(:by) { :state }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(click_through_rate.keys).to eq [state_code] }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(click_through_rate.keys).to eq [state_code] }
          end
        end
      end

      describe 'annotation click-through rate can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          rate = video.annotation_click_through_rate range.merge by: :range
          expect(rate.size).to be 1
          expect(rate[:total]).to be_a Float
        end
      end

      describe 'annotation click-through rate can be grouped by day' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE'], until: Date.parse(ENV['YT_TEST_PARTNER_VIDEO_DATE']) + 5} }

        specify 'without a :by option (default)' do
          annotation_click_through_rate = video.annotation_click_through_rate range
          expect(annotation_click_through_rate.values).to all(be_instance_of Float)
        end

        specify 'with the :by option set to :day' do
          annotation_click_through_rate = video.annotation_click_through_rate range.merge by: :day
          expect(annotation_click_through_rate.values).to all(be_instance_of Float)
        end
      end

      describe 'annotation click-through rate can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          rate = video.annotation_click_through_rate range.merge by: :country
          expect(rate.keys).to all(be_a String)
          expect(rate.keys.map(&:length).uniq).to eq [2]
          expect(rate.values).to all(be_a Float)
        end
      end

      describe 'annotation click-through rate can be grouped by state' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :state' do
          rate = video.annotation_click_through_rate range.merge by: :state
          expect(rate.keys).to all(be_a String)
          expect(rate.keys.map(&:length).uniq).to eq [2]
          expect(rate.values).to all(be_a Float)
        end
      end

      describe 'annotation close rate can be retrieved for a range of days' do
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }
        let(:date_to) { Date.parse(ENV['YT_TEST_PARTNER_VIDEO_DATE']) + 5 }

        specify 'with a given start (:since option) and a given end (:until option)' do
          expect(video.annotation_close_rate(since: date, until: date_to).keys.min).to eq date.to_date
        end

        specify 'with a given start (:from option) and a given end (:to option)' do
          expect(video.annotation_close_rate(from: date, to: date_to).keys.min).to eq date.to_date
        end
      end

      describe 'annotation close_rate can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:annotation_close_rate) { video.annotation_close_rate since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(annotation_close_rate.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(annotation_close_rate.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by country' do
          let(:by) { :country }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(annotation_close_rate.keys).to eq [country_code] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(annotation_close_rate.keys).to eq [country_code] }
          end
        end

        context 'and grouped by state' do
          let(:by) { :state }

          context 'with the :in option set to the country code' do
            let(:location) { country_code }
            it { expect(annotation_close_rate.keys.map(&:length).uniq).to eq [2] }
          end

          context 'with the :in option set to {country: country code}' do
            let(:location) { {country: country_code} }
            it { expect(annotation_close_rate.keys.map(&:length).uniq).to eq [2] }
          end
        end
      end

      describe 'annotation close_rate can be retrieved for a single US state' do
        let(:state_code) { 'CA' }
        let(:close_rate) { video.annotation_close_rate since: date, by: by, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'and grouped by day' do
          let(:by) { :day }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(close_rate.keys.min).to eq date.to_date }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(close_rate.keys.min).to eq date.to_date }
          end
        end

        context 'and grouped by US state' do
          let(:by) { :state }

          context 'with the :in option set to {state: state code}' do
            let(:location) { {state: state_code} }
            it { expect(close_rate.keys).to eq [state_code] }
          end

          context 'with the :in option set to {country: "US", state: state code}' do
            let(:location) { {country: 'US', state: state_code} }
            it { expect(close_rate.keys).to eq [state_code] }
          end
        end
      end

      describe 'annotation close rate can be grouped by range' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :range' do
          rate = video.annotation_close_rate range.merge by: :range
          expect(rate.size).to be 1
          expect(rate[:total]).to be_a Float
        end
      end

      describe 'annotation close rate can be grouped by day' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE'], until: Date.parse(ENV['YT_TEST_PARTNER_VIDEO_DATE']) + 5} }

        specify 'without a :by option (default)' do
          annotation_close_rate = video.annotation_close_rate range
          expect(annotation_close_rate.values).to all(be_instance_of Float)
        end

        specify 'with the :by option set to :day' do
          annotation_close_rate = video.annotation_close_rate range.merge by: :day
          expect(annotation_close_rate.values).to all(be_instance_of Float)
        end
      end

      describe 'annotation close rate can be grouped by country' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :country' do
          rate = video.annotation_close_rate range.merge by: :country
          expect(rate.keys).to all(be_a String)
          expect(rate.keys.map(&:length).uniq).to eq [2]
          expect(rate.values).to all(be_a Float)
        end
      end

      describe 'annotation close rate can be grouped by state' do
        let(:range) { {since: ENV['YT_TEST_PARTNER_VIDEO_DATE']} }

        specify 'with the :by option set to :state' do
          rate = video.annotation_close_rate range.merge by: :state
          expect(rate.keys).to all(be_a String)
          expect(rate.keys.map(&:length).uniq).to eq [2]
          expect(rate.values).to all(be_a Float)
        end
      end

      describe 'viewer percentage can be retrieved for a range of days' do
        let(:viewer_percentage) { video.viewer_percentage since: 1.year.ago, until: 10.days.ago}
        it { expect(viewer_percentage).to be_a Hash }
      end

      describe 'viewer_percentage can be grouped by gender and age group' do
        let(:range) { {since: 1.year.ago.to_date, until: 1.week.ago.to_date} }
        let(:keys) { range.values }

        specify 'without a :by option (default)' do
          viewer_percentage = video.viewer_percentage range
          expect(viewer_percentage.keys).to match_array [:female, :male]
          expect(viewer_percentage[:female].keys - %w(65- 35-44 45-54 13-17 25-34 55-64 18-24)).to be_empty
          expect(viewer_percentage[:female].values).to all(be_instance_of Float)
          expect(viewer_percentage[:male].keys - %w(65- 35-44 45-54 13-17 25-34 55-64 18-24)).to be_empty
          expect(viewer_percentage[:male].values).to all(be_instance_of Float)
        end

        specify 'with the :by option set to :gender_age_group' do
          viewer_percentage = video.viewer_percentage range.merge by: :gender_age_group
          expect(viewer_percentage.keys).to match_array [:female, :male]
          expect(viewer_percentage[:female].keys - %w(65- 35-44 45-54 13-17 25-34 55-64 18-24)).to be_empty
          expect(viewer_percentage[:female].values).to all(be_instance_of Float)
          expect(viewer_percentage[:male].keys - %w(65- 35-44 45-54 13-17 25-34 55-64 18-24)).to be_empty
          expect(viewer_percentage[:male].values).to all(be_instance_of Float)
        end
      end

      describe 'viewer percentage can be retrieved for a single country' do
        let(:country_code) { 'US' }
        let(:viewer_percentage) { video.viewer_percentage since: date, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'with the :in option set to the country code' do
          let(:location) { country_code }
          it { expect(viewer_percentage.keys).to match_array [:female, :male] }
        end

        context 'with the :in option set to {country: country code}' do
          let(:location) { {country: country_code} }
          it { expect(viewer_percentage.keys).to match_array [:female, :male] }
        end
      end

      describe 'viewer percentage can be retrieved for a single US state' do
        let(:state_code) { 'CA' }
        let(:viewer_percentage) { video.viewer_percentage since: date, in: location }
        let(:date) { ENV['YT_TEST_PARTNER_VIDEO_DATE'] }

        context 'with the :in option set to {state: state code}' do
          let(:location) { {state: state_code} }
          it { expect(viewer_percentage.keys).to match_array [:female, :male] }
        end

        context 'with the :in option set to {country: "US", state: state code}' do
          let(:location) { {country: 'US', state: state_code} }
          it { expect(viewer_percentage.keys).to match_array [:female, :male] }
        end
      end

      describe 'viewer percentage can be grouped by gender' do
        let(:range) { {since: 1.year.ago.to_date, until: 1.week.ago.to_date} }
        let(:keys) { range.values }

        specify 'with the :by option set to :gender' do
          viewer_percentage = video.viewer_percentage range.merge by: :gender
          expect(viewer_percentage.keys).to match_array [:female, :male]
          expect(viewer_percentage[:female]).to be_a Float
          expect(viewer_percentage[:male]).to be_a Float
        end
      end

      describe 'viewer_percentage can be grouped by age group' do
        let(:range) { {since: 1.year.ago.to_date, until: 1.week.ago.to_date} }
        let(:keys) { range.values }

        specify 'with the :by option set to :age_group' do
          viewer_percentage = video.viewer_percentage range.merge by: :age_group
          expect(viewer_percentage.keys - %w(65- 35-44 45-54 13-17 25-34 55-64 18-24)).to be_empty
          expect(viewer_percentage.values).to all(be_instance_of Float)
        end
      end
    end

    context 'given a video claimable by the authenticated Content Owner' do
      let(:id) { ENV['YT_TEST_PARTNER_CLAIMABLE_VIDEO_ID'] }

      describe 'the advertising formats can be updated and retrieved' do
        let!(:old_formats) { video.ad_formats }
        let!(:new_formats) { %w(standard_instream overlay trueview_instream).sample(2) }
        before { video.advertising_options_set.update ad_formats: new_formats }
        it { expect(video.ad_formats).to match_array new_formats }
        after { video.advertising_options_set.update ad_formats: old_formats }
      end
    end
  end
end