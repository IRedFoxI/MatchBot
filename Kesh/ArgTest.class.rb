module Kesh

	# A class that helps can be used to help with variable typing and values.
	class ArgTest
	
		# Raises the given exception and prints some info about it.
		def ArgTest::raiseException( exception )
			callList = caller( 2 )
			i = callList.length
			
			caller( 2 ).each do |error| 
				puts "#{i.to_s.rjust(2,' ')}: #{error}"
				i -= 1
			end
			
			puts exception.inspect
			raise exception
		end


		# Tests whether the given variable's value is contained in the Array of possible values in the range Array.
		def ArgTest.valueRange( name, value, range )
			ArgTest::raiseException ArgumentError.new( "Parameter #{name} is not one of the following values: #{range.join( ', ' )}." ) if ( range.index( value ) == nil )
		end
		

		# Test whether the given variable's value is a specific class and if it is nil or not.
		def ArgTest.type( name, value, forceClass = nil, canBeNil = false )
			if ( value == nil )
				ArgTest::raiseException ArgumentError.new( "Parameter #{name} is nil." ) unless canBeNil
			elsif ( forceClass == nil )
				return
			elsif ( forceClass.class == Class )
				ArgTest::raiseException ArgumentError.new( "Parameter #{name} is not a #{forceClass} (#{value.to_s})." ) unless value.is_a?( forceClass )
			elsif ( forceClass.class == Array )
				ArgTest::valueRange( "#{name}.class", value.class, forceClass )
			end
		end
		
		
		# Tests whether the given variable's value lies between the given values.
		def ArgTest.intRange( name, value, minValue = nil, maxValue = nil )
			return if ( minValue == nil && maxValue == nil )
			ArgTest::raiseException ArgumentError.new( "Parameter #{name} is more than #{maxValue}." ) if ( minValue == nil && value > maxValue )
			return if ( minValue == nil )
			ArgTest::raiseException ArgumentError.new( "Parameter #{name} is less than #{minValue} characters." ) if ( maxValue == nil && value < minValue )
			return if ( maxValue == nil )
			ArgTest::raiseException ArgumentError.new( "Parameter #{name} is not within the range of #{minValue} to #{maxValue}." ) if ( value < minValue || value > maxValue )
		end
		
		
		# Tests whether the length of the string lies between the given lengths.
		def ArgTest.stringLength( name, value, minLength = nil, maxLength = nil, strip = false )
			ArgTest::intRange( "#{name}.length", value.length, minLength, maxLength ) if ( !strip )
			ArgTest::intRange( "#{name}.length", value.strip.length, minLength, maxLength ) if ( strip )
		end
		
		
		# Tests whether the given Array's size is between the given values.
		def ArgTest.arraySize( name, value, minElements = nil, maxElements = nil )
			ArgTest::intRange( "#{name}.length", value.length, minElements, maxElements )
		end
		
		
		# Runs the ArgTest::type check on all of an Array's elements.
		def ArgTest.arrayElementClass( name, value, elemClass = nil, canBeNil = false, arrayCanBeNil = false )
			ArgTest::type( name, value, Array, arrayCanBeNil )
			return if ( value == nil )
			
			value.each do |elem|
				ArgTest.type( "#{name}.elem|#{value.to_s}|", elem, elemClass, canBeNil )
			end
		end
		
	end
end
