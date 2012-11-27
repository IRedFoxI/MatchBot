requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class ChanOPrivsNeededNumeric < Kesh::IRC::Events::NumericEvent
				
					def ChanOPrivsNeededNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == ERR_CHANOPRIVSNEEDED
						)
						return ChanOPrivsNeededNumeric.new( server, source, id, target, server.getChannelByName( tokens[ 0 ] ) )
					end
					
				
					attr_reader :channel
					
					def initialize( server, source, id, target, channel )
						super( server, source, id, target )
						Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
						@channel = channel
					end
					
				end
				
			end		
		end
	end
end