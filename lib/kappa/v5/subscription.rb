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
      @sub_plan = hash['sub_plan'] && hash['sub_plan'] != 'Prime' ? hash['sub_plan'].to_i : 1000
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

    # @example
    #   23945610
    # @return [Fixnum] Unique Twitch ID for the subscription.
    attr_reader :sub_plan

    def sub_level
      case sub_plan
        when 1000
          return "$4.99"
        when 2000
          return "$9.99"
        when 3000
          return "$24.99"
        else
          return "n/a: #{sub_plan}"
      end
    end
    
  end

end