requireLibrary '../../DataStructures'

module Kesh
	module DataStructures

		class Comparer
			
			# Returns:
			# * < 0: a is less than b
			# *   0: a and equal to b
			# * > 0: a is greater than b
			def compare( a, b )
				raise NotImplementedError
			end
			
			# Returns true if the objects are equal, false otherwise.
			def equals( a, b )
				return ( compare( a, b ) == 0 )
			end
			
		end
		
	end
end