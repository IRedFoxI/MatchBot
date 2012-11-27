requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class TopicNumeric < Kesh::IRC::Events::NumericEvent
				
					def TopicNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == RPL_TOPIC
						)
						return TopicNumeric.new( server, source, id, target, server.getChannelByName( tokens[ 0 ] ), tokens[ 1 ] )
					end
					
				
					attr_reader :channel
					attr_reader :topic
					
					def initialize( server, source, id, target, channel, topic )
						super( server, source, id, target )
						Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
						Kesh::ArgTest::type( "topic", topic, String )
						@channel = channel
						@topic = topic
					end
					
				end
				
			end		
		end
	end
end