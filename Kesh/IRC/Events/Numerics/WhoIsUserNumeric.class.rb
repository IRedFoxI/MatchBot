requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class WhoIsUserNumeric < Kesh::IRC::Events::NumericEvent
				
					def WhoIsUserNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 5 &&
							id == RPL_WHOISUSER
						)						
						
						return WhoIsUserNumeric.new( server, source, id, target, server.getClientByName( tokens[ 0 ] ), tokens[ 1 ], tokens[ 2 ], tokens[ 4 ] )
					end
					
				
					attr_reader :client
					attr_reader :ident
					attr_reader :host
					attr_reader :realName
					
					def initialize( server, source, id, target, client, ident, host, realName )
						super( server, source, id, target )
						Kesh::ArgTest::type( "client", client, Kesh::IRC::Client )
						Kesh::ArgTest::type( "ident", ident, String )
						Kesh::ArgTest::type( "host", host, String )
						Kesh::ArgTest::type( "realName", realName, String )
						@client = client
						@ident = ident
						@host = host
						@realName = realName
					end
					
				end
				
			end		
		end
	end
end