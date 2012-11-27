requireLibrary '../../IRC'

module Kesh
	module IRC

		class Client

			Regex = "(([^\\s!]+)(!([^\\s@]+))?@)?([^\\s]+)"

			def Client.parse( string )
				Kesh::ArgTest::type( "string", string, String )
				string[/#{Regex}/]
				return [ $2, $4, $5 ]
			end


			attr_reader :server
			attr_accessor :name
			attr_accessor :ident
			attr_accessor :host
			attr_accessor :realName

			def initialize( server, name, ident = nil, host = nil, realName = nil )
				Kesh::ArgTest::type( "server", server, Server )
				Kesh::ArgTest::type( "name", name, String, true )
				Kesh::ArgTest::type( "ident", ident, String, true )
				Kesh::ArgTest::type( "host", host, String, true )
				Kesh::ArgTest::type( "realName", realName, String, true )
				@server = server
				@name = name
				@ident = ident
				@host = host
				@realName = realName
				@channels = []
			end


			def to_s()
				return "#{@name}!#{@ident}@#{@host}" unless ident == nil
				return "#{@name}@#{@host}" unless name == nil
				return @host
			end


			def to_str()
				return to_s()
			end


			private
			def getChannelIndex( mixed )
				Kesh::ArgTest::type( "mixed", mixed, [ String, Channel ] )
				return @channels.index { |c| c.name == mixed } if mixed.is_a?( String )
				return @channels.index( mixed ) if mixed.is_a?( Channel )
			end


			public
			def inChannel?( channel )
				Kesh::ArgTest::type( "channel", channel, Channel )
				return ( getChannelIndex( channel ) != nil )
			end


			def addChannel( channel )
				Kesh::ArgTest::type( "channel", channel, Channel )
				return false if inChannel?( channel )
				@channels << channel
				return true
			end


			def removeChannel( channel )
				Kesh::ArgTest::type( "channel", channel, Channel )
				i = getChannelIndex( channel )
				return false if ( i == nil )
				@channels.delete_at( i )
				return true
			end


			def removeAllChannels()
				channels = []
			end


			def getChannels()
				return ( @channels + [] )
			end


			def channelCount()
				@channels.size
			end


			def isOp( channel )
				Kesh::ArgTest::type( "channel", channel, Channel )
				return false unless inChannel?( channel )
				return channel.clientHasMode?( self, server.getChannelMode( 'o' ) )
			end


			def isHalfOp( channel )
				Kesh::ArgTest::type( "channel", channel, Channel )
				return false unless inChannel?( channel )
				return channel.clientHasMode?( self, server.getChannelMode( 'h' ) )
			end


			def isVoice( channel )
				Kesh::ArgTest::type( "channel", channel, Channel )
				return false unless inChannel?( channel )
				return channel.clientHasMode?( self, server.getChannelMode( 'v' ) )
			end


			def isBanned( channel )
				Kesh::ArgTest::type( "channel", channel, Channel )
				return false unless inChannel?( channel )
				return channel.clientMatchesMode?( self, server.getChannelMode( 'b' ) )
			end


			def getLevel( channel )
				Kesh::ArgTest::type( "channel", channel, Channel )
				return server.getChannelMode( 'o' ) if isOp( channel )
				return server.getChannelMode( 'h' ) if isHalfOp( channel )
				return server.getChannelMode( 'v' ) if isVoice( channel )
				return nil
			end

		end

	end
end




