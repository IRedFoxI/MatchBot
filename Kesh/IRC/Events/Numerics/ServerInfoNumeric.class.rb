requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class ServerInfoNumeric < Kesh::IRC::Events::NumericEvent
				
					def ServerInfoNumeric.parse( server, source, id, target, tokens )						
						return nil unless ( 
							tokens.length == 1 &&
							id == RPL_YOURHOST
						)
						
						tokens[ 0 ][/^Your host is ([^,]+), running version (.+)$/]
						
						return ServerInfoNumeric.new( server, source, id, target, $1, $2 )
					end
					
				
					attr_reader :host
					attr_reader :version
					
					def initialize( server, source, id, target, host, version )
						super( server, source, id, target )
						Kesh::ArgTest::type( "host", host, String )
						Kesh::ArgTest::type( "version", version, String )
						@host = host
						@version = version
					end
					
				end
				
			end		
		end
	end
end