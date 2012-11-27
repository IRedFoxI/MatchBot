requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class WhoIsIdleNumeric < Kesh::IRC::Events::NumericEvent
				
					def WhoIsIdleNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 3 &&
							id == RPL_WHOISIDLE
						)						
						
						return WhoIsIdleNumeric.new( server, source, id, target, server.getClientByName( tokens[ 0 ] ), Integer( tokens[ 1 ] ) )
					end
					
				
					attr_reader :client
					attr_reader :time
					
					def initialize( server, source, id, target, client, time )
						super( server, source, id, target )
						Kesh::ArgTest::type( "client", client, Kesh::IRC::Client )
						Kesh::ArgTest::type( "time", time, Fixnum )
						@client = client
						@time = time
					end
					
				end
				
			end		
		end
	end
end