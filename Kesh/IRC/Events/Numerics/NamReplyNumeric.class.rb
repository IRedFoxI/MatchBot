requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics

				class NamReplyNumeric < Kesh::IRC::Events::NumericEvent

					def NamReplyNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 3 &&
							id == RPL_NAMREPLY
						)

						clientList = []

						tokens[ 2 ].split( ' ' ).each do |c|
							mode = server.getModeForClientPrefix( c )

							if ( mode == nil )
								clientList << [ server.getClientByName( c ), nil ]

							else
								clientList << [ server.getClientByName( c[ 1..-1 ] ), mode ]
							end
						end

						return NamReplyNumeric.new( server, source, id, target, server.getChannelByName( tokens[ 1 ] ), clientList )
					end


					attr_reader :channel
					attr_reader :clientList

					def initialize( server, source, id, target, channel, clientList )
						super( server, source, id, target )
						Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
						Kesh::ArgTest::type( "clientList", clientList, Array )
						@channel = channel
						@clientList = clientList
					end

				end

			end
		end
	end
end
