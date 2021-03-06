require 'cgi'
require 'time'

module Twitch::V5
  # Channels serve as the home location for a user's content. Channels have a stream, can run
  # commercials, store videos, display information and status, and have a customized page including
  # banners and backgrounds.
  # @see Channels#get Channels#get
  # @see Channels
  # @see Stream
  # @see User
  class Channel
    include Twitch::IdEquality

    # @private
    def initialize(hash, query)
      @query = query
      @id = hash['_id']
      @background_url = hash['background']
      @banner_url = hash['banner']
      @created_at = Time.parse(hash['created_at']).utc
      @display_name = hash['display_name']
      @game_name = hash['game']
      @logo_url = hash['logo']
      @mature = hash['mature'] || false
      @name = hash['name']
      @status = hash['status']
      @updated_at = Time.parse(hash['updated_at']).utc
      @url = hash['url']
      @video_banner_url = hash['video_banner']

      @teams = []
    end

    # Does this channel have mature content? This flag is specified by the owner of the channel.
    # @return [Boolean] `true` if the channel has mature content, `false` otherwise.
    def mature?
      @mature
    end

    # Get the live stream associated with this channel.
    # @note This incurs an additional web request.
    # @return [Stream] Live stream object for this channel, or `nil` if the channel is not currently streaming.
    # @see #streaming?
    def stream
      @query.streams.get(@id)
    end

    # Does this channel currently have a live stream?
    # @note This makes a separate request to get the channel's stream. If you want to actually use the stream object, you should call `#stream` instead.
    # @return [Boolean] `true` if the channel currently has a live stream, `false` otherwise.
    # @see #stream
    def streaming?
      !stream.nil?
    end

    # Get the owner of this channel.
    # @note This incurs an additional web request.
    # @return [User] The user that owns this channel.
    def user
      @query.users.get(@id)
    end

    # Get the users following this channel.
    # @note The number of followers is potentially very large, so it's recommended that you specify a `:limit`.
    # @example
    #   channel.followers(:limit => 20)
    # @example
    #   channel.followers do |follower|
    #     puts follower.display_name
    #   end
    # @param options [Hash] Filter criteria.
    # @option options [Fixnum] :limit (nil) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @yield Optional. If a block is given, each follower is yielded.
    # @yieldparam [User] follower Current follower.
    # @see User
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/channels.md#get-channelschannelfollows GET /channels/:channel/follows
    # @return [Array<User>] Users following this channel, if no block is given.
    # @return [nil] If a block is given.
    def followers(options = {}, &block)
      id = CGI.escape(@id)
      return @query.connection.accumulate(
        :path => "channels/#{id}/follows",
        :json => 'follows',
        :sub_json => 'user',
        :create => -> hash { User.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

    # Get the videos for a channel, most recently created first.
    # @note This incurs additional web requests.
    # @note You can get videos directly from a channel name via {Videos#for_channel}.
    # @example
    #   v = channel.videos(:type => :broadcasts)
    # @example
    #   channel.videos(:type => :highlights) do |video|
    #     next if video.view_count < 10000
    #     puts video.url
    #   end
    # @param options [Hash] Filter criteria.
    # @option options [Symbol] :type (:highlights) The type of videos to return. Valid values are `:broadcasts`, `:highlights`.
    # @option options [Fixnum] :limit (nil) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @yield Optional. If a block is given, each video is yielded.
    # @yieldparam [Video] video Current video.
    # @see Video
    # @see Videos#for_channel Videos#for_channel
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/videos.md#get-channelschannelvideos GET /channels/:channel/videos
    # @raise [ArgumentError] If `:type` is not one of `:broadcasts` or `:highlights`.
    # @return [Array<Video>] Videos for the channel, if no block is given.
    # @return [nil] If a block is given.
    def videos(options = {}, &block)
      @query.videos.for_channel(@id, options, &block)
    end

    # Get the users subscribing to this channel.
    # @note The number of followers is potentially very large, so it's recommended that you specify a `:limit`.
    # @note This incurs additional web requests.
    # @example
    #   channel.subscriptions(:limit => 20)
    # @example
    #   channel.subscriptions do |sub|
    #     puts sub.created_at
    #     puts sub.user.name
    #   end
    # @param options [Hash] Limit/offset information.
    # @option options [Fixnum] :limit (nil) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @yield Optional. If a block is given, each subscription is yielded.
    # @yieldparam [Subscription] subscription Current subscription.
    # @see https://github.com/justintv/Twitch-API/blob/master/v3_resources/subscriptions.md#get-channelschannelsubscriptions
    # @return [Array<Subscription>] Subscriptions to this channel, if no block is given.
    # @return [nil] If a block is given.
    def subscriptions(options = {}, &block)
      id = CGI.escape(@id)
      return @query.connection.accumulate(
        :path => "channels/#{id}/subscriptions",
        :json => 'subscriptions',
        :create => -> hash { Subscription.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

    # @example
    #   23460970
    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/lethalfrag-channel_background_image-833a4324bc698c9b.jpeg"
    # @return [String] URL for background image.
    attr_reader :background_url

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/lethalfrag-channel_header_image-463a4670c91c2b61-640x125.jpeg"
    # @return [String] URL for banner image.
    attr_reader :banner_url

    # @example
    #   2011-07-15 07:53:58 UTC
    # @return [Time] When the channel was created (UTC).
    attr_reader :created_at

    # @example
    #   "Lethalfrag"
    # @see #name
    # @return [String] User-friendly display name. This name is used for the channel's page title.
    attr_reader :display_name

    # @example
    #   "Super Meat Boy"
    # @return [String] Name of the primary game for this channel.
    attr_reader :game_name

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/lethalfrag-profile_image-050adf252718823b-300x300.png"
    # @return [String] URL for the logo image.
    attr_reader :logo_url

    # @example
    #   "lethalfrag"
    # @see #display_name
    # @return [String] Unique Twitch name.
    attr_reader :name

    # @example
    #   "(Day 563/731) | Dinner and a Game (Cooking at http://twitch.tv/lookatmychicken)"
    # @return [String] Current status set by the channel's owner.
    attr_reader :status

    # @example
    #   2013-07-21 05:27:58 UTC
    # @return [Time] When the channel was last updated (UTC). For example, when a stream is started or a channel's status is changed, the channel is updated.
    attr_reader :updated_at

    # @example
    #   "http://www.twitch.tv/lethalfrag"
    # @return [String] The URL for the channel's main page.
    attr_reader :url

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/lethalfrag-channel_offline_image-3b801b2ccc11830b-640x360.jpeg"
    # @return [String] URL for the image shown when the stream is offline.
    attr_reader :video_banner_url

    # @see Team
    # @return [Array<Team>] The list of teams that this channel is associated with. Not all channels have associated teams.
    attr_reader :teams
  end

  # Query class for finding channels.
  # @see Channel
  class Channels
    # @private
    def initialize(query)
      @query = query
    end

    # Get a channel by name.
    # @example
    #   c = Twitch.channels.get('day9tv')
    # @param channel_name [String] The name of the channel to get. This is the same as the stream or user name.
    # @return [Channel] A valid `Channel` object if the channel exists, `nil` otherwise.
    def get(channel_id)
      id = CGI.escape(channel_id)

      # HTTP 422 can happen if the channel is associated with a Justin.tv account.
      Twitch::Status.map(404 => nil, 422 => nil) do
        json = @query.connection.get("channels/#{id}")
        Channel.new(json, @query)
      end
    end

    # Shortcut method: Return's a channel's list of subscribers.
    # @example
    #   c = Twitch.channels.subscribers('111111')
    # @param channel_id [String] The ID of the channel to get subscribers for.
    # @return [Array<Subscription>] Returns an array containing Subscription objects representing those subscriptions.
    def subscriptions(channel_id, options={},&block)
      id = CGI.escape(channel_id)
      return @query.connection.accumulate(
        :path => "channels/#{id}/subscriptions",
        :json => 'subscriptions',
        :create => -> hash { Subscription.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

	def subscribed?( user_name, channel_name )
      user_name = CGI.escape(user_name)
      channel_name = CGI.escape(channel_name)

      Twitch::Status.map(404 => false, 400 => false, 401 => false) do
        data = @query.connection.get("channels/#{channel_name}/subscriptions/#{user_name}")
        true
      end
    end	
  end
end
