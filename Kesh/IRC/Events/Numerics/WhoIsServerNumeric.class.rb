requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class WhoIsServerNumeric < Kesh::IRC::Events::NumericEvent
				
					def WhoIsServerNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 3 &&
							id == RPL_WHOISSERVER
						)						
						
						return WhoIsServerNumeric.new( server, source, id, target, server.getClientByName( tokens[ 0 ] ), tokens[ 1 ], tokens[ 2 ] )
					end
					
				
					attr_reader :client
					attr_reader :serverHost
					attr_reader :serverInfo
					
					def initialize( server, source, id, target, client, serverHost, serverInfo )
						super( server, source, id, target )
						Kesh::ArgTest::type( "client", client, Kesh::IRC::Client )
						Kesh::ArgTest::type( "serverHost", serverHost, String )
						Kesh::ArgTest::type( "serverInfo", serverInfo, String )
						@client = client
						@serverHost = serverHost
						@serverInfo = serverInfo
					end
					
				end
				
			end		
		end
	end
end