requireLibrary '../../DataStructures'

module Kesh
	module DataStructures
	
		class Heap
		
			# Initialize the heap.
			def initialize( comparer )
				Kesh::ArgTest::type( "comparer", comparer, Comparer )
				@comparer = comparer
				@array = []
				@maxIndex = -1
			end
			
			
			# Add a value to the heap.
			def add( value )
				Kesh::ArgTest::type( "value", value, Object )
				@maxIndex += 1
				@array[ @maxIndex ] = value
				index = moveUp( @maxIndex )
				moveDown( index )
			end
			
			
			# Return the first element of the heap.
			def peak()
				return nil if ( @maxIndex == -1 )
				return @array[ 0 ]
			end
			
			
			# Remove and return the first element of the heap.
			def removeFirst()
				return removeIndex( 0 )
			end
			
			
			# Remove and return the last element of the heap.
			def removeLast()
				return removeIndex( @maxIndex )
			end
			
			
			# Remove and the given index from the heap.
			def removeIndex( index )
				Kesh::ArgTest::type( "index", index, Fixnum )
				Kesh::ArgTest::intRange( "index", index, 0, @maxIndex )
				
				if ( index == @maxIndex )
					value = @array[ index ]
					@array[ index ] = nil
					@maxIndex -= 1
					
				else
					value = @array[ index ]
					@array[ index ] = @array[ @maxIndex ]
					@array[ @maxIndex ] = nil
					@maxIndex -= 1
					index = moveUp( index )
					moveDown( index )
				end
				
				return value
			end
			
			
			# Returns true if the value was removed from the heap, false otherwise.
			def removeValue( value )				
				return false if ( @maxIndex == -1 )					
				
				index = nil

				[ 0..@maxIndex ].map.each do |i|
					if ( value == @array[ i ] )
						index = i
						break
					end
				end
				
				return false if ( index == nil )
				
				removeIndex( index )
				return true
			end
			
			
			# Returns the current size of the heap.
			def count()
				return ( @maxIndex + 1 )
			end
			
			
			private
			def getParentIndex( index )
				( ( index - 1 ) / 2 ).floor.to_i
			end
			
			
			def getFirstChildIndex( index )
				return ( ( index * 2 ) + 1 )
			end
			
			
			def getSecondChildIndex( index )
				return ( ( index * 2 ) + 2 )
			end
		
			
			def moveUp( index )
				return 0 if ( index == 0 )
				
				pIndex = getParentIndex( index )
				
				# If child > parent
				if ( @comparer.compare( @array[ index ], @array[ pIndex ] ) > 0 )
					value = @array[ pIndex ]
					@array[ pIndex ] = @array[ index ]
					@array[ index ] = value
					return moveUp( pIndex )
				end
				
				return index
			end
			
			
			def moveDown( index )
				c1Index = getFirstChildIndex( index )
				c2Index = getSecondChildIndex( index )
				
				return index if ( c1Index > @maxIndex && c2Index > @maxIndex )
				
				if ( c2Index >= @maxIndex )
					greatestChildIndex = c1Index					
				else
					greatestChildIndex = @comparer.compare( @array[ c1Index ], @array[ c2Index ] ) >= 0 ? c1Index : c2Index
				end
				
				# If parent < child
				if ( @comparer.compare( @array[ index ], @array[ greatestChildIndex ] ) < 0 )
					value = @array[ index ]
					@array[ index ] = @array[ greatestChildIndex ]
					@array[ greatestChildIndex ] = value
					return moveDown( greatestChildIndex )
				end
				
				return index
			end
			
		end
		
	end
end				
					