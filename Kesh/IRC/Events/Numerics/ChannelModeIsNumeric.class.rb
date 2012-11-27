requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class ChannelModeIsNumeric < Kesh::IRC::Events::NumericEvent
				
					def ChannelModeIsNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length >= 2 &&
							id == RPL_CHANNELMODEIS
						)
						
						channel = server.getChannelByName( tokens[ 0 ] )
						modeString = tokens[ 1 ]
						tokens.shift( 2 )
						tokens = [] if ( tokens == nil )
						modeArray = Kesh::IRC::Events::ChannelModeEvent.getChannelModeArrayFromString( channel, modeString, tokens )
						
						return ChannelModeIsNumeric.new( server, source, id, target, channel, modeArray )
					end
					
					
					attr_reader :channel
					attr_reader :modeArray
				
					def initialize( server, source, id, target, channel, modeArray )
						super( server, source, id, target )
						Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
						Kesh::ArgTest::type( "modeArray", modeArray, Array )
						@channel = channel
						@modeArray = modeArray
					end
					
				end
				
			end		
		end
	end
end