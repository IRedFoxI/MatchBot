requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class ErroneusNicknameNumeric < Kesh::IRC::Events::NumericEvent
				
					def ErroneusNicknameNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == ERR_ERRONEUSNICKNAME
						)
						return ErroneusNicknameNumeric.new( server, source, id, target, tokens[ 0 ] )
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