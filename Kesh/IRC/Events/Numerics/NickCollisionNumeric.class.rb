requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class NickCollisionNumeric < Kesh::IRC::Events::NumericEvent
				
					def NickCollisionNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == ERR_NICKCOLLISION
						)
						return NickCollisionNumeric.new( server, source, id, target, tokens[ 0 ] )
					end
					
				
					attr_reader :nickname
					
					def initialize( server, source, id, target, nickname )
						super( server, source, id, target )
						Kesh::ArgTest::type( "nickname", nickname, String )
						@nickname = nickname
					end
					
				end
				
			end		
		end
	end
end