requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class AwayNumeric < Kesh::IRC::Events::NumericEvent
				
					def AwayNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == RPL_AWAY
						)
						return AwayNumeric.new( server, source, id, target, server.getClientByName( tokens[ 0 ] ), tokens[ 1 ] )
					end
					
				
					attr_reader :client
					attr_reader :message
					
					def initialize( server, source, id, target, client, message )
						super( server, source, id, target )
						Kesh::ArgTest::type( "client", client, Kesh::IRC::Client )
						Kesh::ArgTest::type( "message", message, String )
						@client = client
						@message = message
					end
					
				end
				
			end		
		end
	end
end