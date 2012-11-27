requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class WhoReplyNumeric < Kesh::IRC::Events::NumericEvent
				
					def WhoReplyNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 5 &&
							id == RPL_WHOREPLY
						)
						
						channel = server.getChannelByName( tokens[ 0 ] )
						client = server.getClientByName( tokens[ 1 ] )
						string = tokens[ 2 ]
						hostmask = tokens[ 3 ]
						
						moreTokens = tokens[ 4 ].split( ' ', 2 )
						hopCount = Integer( moreTokens[ 0 ] )
						realName = moreTokens[ 1 ]
						
						return WhoReplyNumeric.new( server, source, id, target, channel, client, string, hostmask, hopCount, realName )
					end
					
				
					attr_reader :channel
					attr_reader :client
					attr_reader :string
					attr_reader :hostmask
					attr_reader :hopCount
					attr_reader :realName
					
					def initialize( server, source, id, target, channel, client, string, hostmask, hopCount, realName )
						super( server, source, id, target )
						Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
						Kesh::ArgTest::type( "client", client, Kesh::IRC::Client )
						Kesh::ArgTest::type( "string", string, String )
						Kesh::ArgTest::type( "hostmask", hostmask, String )
						Kesh::ArgTest::type( "hopCount", hopCount, Fixnum )
						Kesh::ArgTest::type( "realName", realName, String )
						@channel = channel
						@client = client
						@string = string
						@hostmask = hostmask
						@hopCount = hopCount
						@realName = realName
					end
					
				end
				
			end		
		end
	end
end