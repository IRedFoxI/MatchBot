requireLibrary '../../IRC'

module Kesh
	module IRC
		
		class Command
	
			def format
				raise NotImplementedError.new( "Command has not completed it's format method." )
			end

		end
		
	end
end
