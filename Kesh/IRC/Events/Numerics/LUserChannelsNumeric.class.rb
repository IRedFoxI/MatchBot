requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class LUserChannelsNumeric < Kesh::IRC::Events::NumericEvent
				
					def LUserChannelsNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == RPL_LUSERCHANNELS
						)
						
						return LUserChannelsNumeric.new( server, source, id, target, Integer( tokens[ 0 ] ) )
					end
					
				
					attr_reader :channels
				
					def initialize( server, source, id, target, channels )
						super( server, source, id, target )
						Kesh::ArgTest::type( "channels", channels, Fixnum )
						@channels = channels
					end
					
				end
				
			end		
		end
	end
end