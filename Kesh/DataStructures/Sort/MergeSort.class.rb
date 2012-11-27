requireLibrary '../../../DataStructures'
requireClass '../Comparer'

module Kesh
	module DataStructures
		module Sort
		
			class MergeSort
			
				def initialize( comparer )
					Kesh::ArgTest::type( "comparer", comparer, Kesh::DataStructures::Comparer )
					@comparer = comparer
				end
				
				
				def sort( array )
					Kesh::ArgTest::type( "array", array, Array )
					down( array, 0, array.length )
				end
				
				
				private
				def down( array, startIndex, endIndex )
					size = endIndex - startIndex
					
					return if ( size < 2 )
						
					sectionSize = ( size / 2 ) if ( ( size % 2 ) == 0 )
					sectionSize = ( ( size + 1 ) / 2 ) if ( ( size % 2 ) == 1 )
					
					middle = startIndex + sectionSize
					
					down( array, startIndex,  middle )
					down( array, middle,      endIndex )
					up(   array, startIndex,  endIndex )
				end
				
				
				def up( array, startIndex, endIndex )
					size = endIndex - startIndex
					
					return if ( size == 1 )						

					sectionSize = ( size / 2 ) if ( ( size % 2 ) == 0 )
					sectionSize = ( ( size + 1 ) / 2 ) if ( ( size % 2 ) == 1 )
	
					aPtr = 0
					aEnd = sectionSize
					
					bPtr = sectionSize
					bEnd = endIndex - startIndex
					
					slice = array.slice( startIndex, endIndex - startIndex )
					sPtr = 0
					
					while ( aPtr < aEnd || bPtr < bEnd )
						
						if ( aPtr >= aEnd )
							array[ startIndex + sPtr ] = slice[ bPtr ]
							bPtr = bPtr + 1
							
						elsif ( bPtr >= bEnd )
							array[ startIndex + sPtr ] = slice[ aPtr ]
							aPtr = aPtr + 1
							
						elsif( @comparer.compare( slice[ aPtr ], slice[ bPtr ] ) <= 0 )
							array[ startIndex + sPtr ] = slice[ aPtr ]
							aPtr = aPtr + 1
							
						else
							array[ startIndex + sPtr ] = slice[ bPtr ]
							bPtr = bPtr + 1
							
						end
						
						sPtr = sPtr + 1						
					end
				end
				
			end
			
		end
	end
end
