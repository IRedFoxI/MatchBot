requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class WhoIsChannelsNumeric < Kesh::IRC::Events::NumericEvent
				
					def WhoIsChannelsNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == RPL_WHOISCHANNELS
						)
						
						chanList = []
						
						tokens[ 1 ].split( ' ' ).each do |c|
							mode = server.getModeForClientPrefix( c )
							
							if ( mode == nil )
								chanList << [ server.getChannelByName( c ), nil ]
								
							else
								chanList << [ server.getChannelByName( c[ 1..-1 ] ), mode ]
							end
						end
						
						return WhoIsChannelsNumeric.new( server, source, id, target, server.getClientByName( tokens[ 0 ] ), chanList )
					end
					
				
					attr_reader :client
					attr_reader :chanList
					
					def initialize( server, source, id, target, client, chanList )
						super( server, source, id, target )
						Kesh::ArgTest::type( "client", client, Kesh::IRC::Client )
						Kesh::ArgTest::type( "chanList", chanList, Array )
						@client = client
						@chanList = chanList
					end
					
				end
				
			end		
		end
	end
end