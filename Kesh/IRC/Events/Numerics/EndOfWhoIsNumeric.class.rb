requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class EndOfWhoIsNumeric < Kesh::IRC::Events::NumericEvent
				
					def EndOfWhoIsNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == RPL_ENDOFWHOIS
						)						
						
						return EndOfWhoIsNumeric.new( server, source, id, target, server.getClientByName( tokens[ 0 ] ) )
					end
					
				
					attr_reader :client
					
					def initialize( server, source, id, target, client )
						super( server, source, id, target )
						Kesh::ArgTest::type( "client", client, Kesh::IRC::Client )
						@client = client
					end
					
				end
				
			end		
		end
	end
end