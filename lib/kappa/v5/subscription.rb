require 'cgi'
require 'time'

module Twitch::V5
  # These are members of the Twitch community who have a Twitch account. If broadcasting,
  # they can own a stream that they can broadcast on their channel. If mainly viewing,
  # they might follow or subscribe to channels.
  # @see Users#get Users#get
  # @see Users
  # @see Channel
  # @see Stream
  class Subscription
    include Twitch::IdEquality

    # @private
    def initialize(hash, query)
      @query = query
      @id = hash['_id']
      @created_at = Time.parse(hash['created_at']).utc
      @user = User.new( hash['user'], query )
    end

    # @example
    #   23945610
    # @return [Fixnum] Unique Twitch ID for the subscription.
    attr_reader :id

    # @example
    #   2011-08-08 21:03:44 UTC
    # @return [Time] When the subscription was created (UTC).
    attr_reader :created_at

    # @example
    #   2013-07-19 23:51:43 UTC
    # @return [User] A user object with Twitch user data.
    attr_reader :user

  end

end