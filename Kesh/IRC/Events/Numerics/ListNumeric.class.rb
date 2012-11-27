requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class ListNumeric < Kesh::IRC::Events::NumericEvent
				
					def ListNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 3 &&
							id == RPL_LIST
						)
						return ListNumeric.new( server, source, id, target, server.getChannelByName( tokens[ 0 ] ), Integer( tokens[ 1 ] ), tokens[ 2 ] )
					end
					
				
					attr_reader :channel
					attr_reader :userCount
					attr_reader :topic
					
					def initialize( server, source, id, target, channel, userCount, topic )
						super( server, source, id, target )
						Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
						Kesh::ArgTest::type( "userCount", userCount, Fixnum )
						Kesh::ArgTest::type( "topic", topic, String )
						@channel = channel
						@userCount = userCount
						@topic = topic
					end
					
				end
				
			end		
		end
	end
end