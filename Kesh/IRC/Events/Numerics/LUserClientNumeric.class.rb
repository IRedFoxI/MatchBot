requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class LUserClientNumeric < Kesh::IRC::Events::NumericEvent
				
					def LUserClientNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 1 &&
							id == RPL_LUSERCLIENT
						)
						
						tokens[ 0 ][/^There are (\d+) users and (\d+) invisible on (\d+) servers$/]
						users = Integer( $1 )
						invis = Integer( $2 )
						servers = Integer( $3 )
						
						return LUserClientNumeric.new( server, source, id, target, users, invis, servers )
					end
					
				
					attr_reader :users
					attr_reader :invisible
					attr_reader :servers
				
					def initialize( server, source, id, target, users, invisible, servers )
						super( server, source, id, target )
						Kesh::ArgTest::type( "users", users, Fixnum )
						Kesh::ArgTest::type( "invisible", invisible, Fixnum )
						Kesh::ArgTest::type( "servers", servers, Fixnum )
						@users = users
						@invisible = invisible
						@servers = servers
					end
					
				end
				
			end		
		end
	end
end