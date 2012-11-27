requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class WhoCommand < Kesh::IRC::Command
			
				attr_reader :mask
				
				def initialize( mask )
					super()
					Kesh::ArgTest::type( "mask", mask, String )
					mask.strip!()
					Kesh::ArgTest::stringLength( "mask", mask, 1 )
					@mask = mask
				end
				

				def format
					return "WHO #{@mask}"
				end				
				
			end
		
		end
	end
end