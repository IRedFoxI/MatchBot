requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class InvitingNumeric < Kesh::IRC::Events::NumericEvent
				
					def InvitingNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == RPL_INVITING
						)
						return InvitingNumeric.new( server, source, id, target, server.getChannelByName( tokens[ 0 ] ), server.getClientByName( tokens[ 1 ] ) )
					end
					
				
					attr_reader :channel
					attr_reader :client
					
					def initialize( server, source, id, target, channel, client )
						super( server, source, id, target )
						Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
						Kesh::ArgTest::type( "client", client, Kesh::IRC::Client )
						@channel = channel
						@client = client
					end
					
				end
				
			end		
		end
	end
end