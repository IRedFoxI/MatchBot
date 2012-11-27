requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class LUserMeNumeric < Kesh::IRC::Events::NumericEvent
				
					def LUserMeNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 1 &&
							id == RPL_LUSERME
						)
						
						tokens[ 0 ][/^I have (\d+) clients and (\d+) servers$/]
						clients = Integer( $1 )
						servers = Integer( $2 )
						
						return LUserMeNumeric.new( server, source, id, target, clients, servers )
					end
					
				
					attr_reader :clients
					attr_reader :servers
				
					def initialize( server, source, id, target, clients, servers )
						super( server, source, id, target )
						Kesh::ArgTest::type( "clients", clients, Fixnum )
						Kesh::ArgTest::type( "servers", servers, Fixnum )
						@clients = clients
						@servers = servers
					end
					
				end
				
			end		
		end
	end
end