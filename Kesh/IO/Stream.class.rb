requireLibrary '../../IO'

module Kesh
	module IO
	
		class Stream
		
			# Read the given number of chars from the Stream.
			def read( maxLength, block = true )
				raise NotImplementedError
			end
			
			# Read, but not remove, the given number of bytes from the Stream.
			def peak( maxLength, block = true )
				raise NotImplementedError
			end
			
			
			# Read a string, up to \n.  Blocks.
			def readLine()
				buffer = ""

				begin
					char = read( 1 )
					buffer << char if ( char != "\n" && char != nil )
				end until ( char == "\n" || char == nil )
				
				return nil if ( buffer == "" )
				
				return buffer.chomp
			end
			
			
			# Write the given string to the Stream.			
			def write( string )
				raise NotImplementedError
			end
			
			
			# Write the given string to the Stream, with a new line character added to the end.
			def writeLine( string )
				write( string + "\n" )
			end
			
		end
	
	end
end
