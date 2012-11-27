requireLibrary '../../Asynchronousity'

module Kesh
	module Asynchronousity
	
		# A callback object used by the TimerSystem
		class TimerCallback
		
			# The timestamp when the callback will be first called
			attr_reader :start
			
			# Initialize our TimerCallback!
			#
			# * start: Timestamp when the timer is first called.
			# * callback: Method run when the time is up.
			# * count: The number of times the timer will be called.
			# * timeBetween: The time between subsequent calls.
			# * stateObj: Passed to the callback when the timer is up.
			def initialize( timerSystem, start, callback, count, timeBetween, stateObj )
				Kesh::ArgTest::type( "timerSystem", timerSystem, TimerSystem )
				Kesh::ArgTest::type( "start", start, Float )
				Kesh::ArgTest::type( "callback", callback, Method )
				Kesh::ArgTest::type( "stateObj", stateObj, Object, true )
				Kesh::ArgTest::type( "count", count, Fixnum )
				Kesh::ArgTest::intRange( "count", count, 0 )
				Kesh::ArgTest::type( "timeBetween", timeBetween, Float )
				Kesh::ArgTest::intRange( "timeBetween", timeBetween, 0 ) if ( count == 1 )
				Kesh::ArgTest::intRange( "timeBetween", timeBetween, 0.05 ) if ( count > 1 )
				@timerSystem = timerSystem
				@start = start
				@callback = callback
				@stateObj = stateObj
				@count = count
				@timeBetween = timeBetween
				@stop = false
			end
			
			
			# Called when the timer reaches zero.  Returning false will prevent the timer from being added to the job queue.
			def syncCall()
				return false if ( @stop == true )
					
				# 0 = infinite
				if ( @count > 0 )
					@count -= 1
					return false if ( @count == 0 )
				end
				
				@start += @timeBetween					
				return true
			end			
			
			
			# Called when the job is started.
			def asyncCallStart( job )
				return if ( @stop == true )
				
				begin
					@stop = @callback.call( @stateObj )
				rescue Exception
				end
			end
			
			
			# Called when the job is finished.
			def asyncCallFinished( job )
				return if ( @stop == false )
				
				begin
					@timerSystem.removeTimer( self )
				rescue Exception
				end
			end
			
		end
		
	end
end
				