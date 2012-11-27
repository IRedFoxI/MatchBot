requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class BanListNumeric < Kesh::IRC::Events::NumericEvent
				
					def BanListNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == RPL_BANLIST
						)
						return BanListNumeric.new( server, source, id, target, server.getChannelByName( tokens[ 0 ] ), tokens[ 1 ] )
					end
					
				
					attr_reader :channel
					attr_reader :mask
					
					def initialize( server, source, id, target, channel, mask )
						super( server, source, id, target )
						Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
						Kesh::ArgTest::type( "mask", mask, String )
						@channel = channel
						@mask = mask
					end
					
				end
				
			end		
		end
	end
end