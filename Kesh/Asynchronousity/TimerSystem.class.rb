requireLibrary '../../Asynchronousity'
requireLibrary '../../DataStructures'
requireClass 'ThreadControl'

module Kesh
	module Asynchronousity
	
		# A system that runs callbacks after certain amounts of time.
		class TimerSystem < ThreadControl
		
			# Initialize the timer system with the given number of asynchronous worker threads.
			def initialize( workerCount )
				Kesh::ArgTest::type( "workerCount", workerCount, Fixnum )
				Kesh::ArgTest::intRange( "workerCount", workerCount, 1, 99 ) # lots of threads...

				@heap = Kesh::DataStructures::Heap.new( TimerComparer.new() )
				@worker = AsyncWorker.new( workerCount )
			end
			
			
			protected
			def stopping?()
				return true if @stop
				return ( @heap.peak() == nil )
			end
			
			
			def notStopping()
				nextTimer = @heap.peak()
				sleepTime = nextTimer.start - Time.now.to_f
				
				if ( sleepTime > 0 )
					@status = :thread_status_sleeping
					sleep( sleepTime )
					@status = :thread_status_working
				
				else
					@worker.addJob( Job.new( nextTimer.method( "asyncCallStart" ), nextTimer.method( "asyncCallFinished" ) ) )
					keep = nextTimer.syncCall()
					
					Thread.exclusive {						
						@heap.removeFirst()
						@heap.add( nextTimer ) if keep
					}									
				end
			end

			
			public
			# Add a non-repeating timer callback.  
			#
			# * Time can be either a timestamp or the time until the timer should return.
			# * StateObj will be passed to the callback method when it is called.
			def addTimer( time, callback, stateObj = nil )
				Kesh::ArgTest::type( "time", time, Float )
				time += Time.now.to_f if ( time < 1300000000.0 ) # convert "in x seconds" to "at x seconds"
				Kesh::ArgTest::intRange( "time", time, Time.now.to_f )
				Kesh::ArgTest::type( "callback", callback, Method )
				Kesh::ArgTest::type( "stateObj", stateObj, Object, true )
				
				timer = TimerCallback.new( self, time, method, 1, 0, stateObj )
				
				Thread.exclusive {
					@heap.add( timer )
				}

				wake()				
				return timer
			end
			
			
			# Add a repeating timer callback.
			#  
			# * Start can be either a timestamp or the time until the timer should first return.
			# * Count is the number of times the timer will run.
			# * timeBetween is the time between subsequent calls.
			# * StateObj will be passed to the callback method when it is called.
			#
			# If the callback method returns false, it will stop the timer from being called again.
			def addRepeatingTimer( start, callback, count, timeBetween, stateObj = nil )
				Kesh::ArgTest::type( "start", start, Float )
				start += Time.now.to_f if ( start < 1300000000.0 ) # convert "in x seconds" to "at x seconds"
				Kesh::ArgTest::intRange( "start", start, Time.now.to_f )
				Kesh::ArgTest::type( "callback", callback, Method )
				Kesh::ArgTest::type( "count", count, Fixnum )
				Kesh::ArgTest::intRange( "count", count, 0 )
				Kesh::ArgTest::type( "timeBetween", timeBetween, Float )
				Kesh::ArgTest::intRage( "timeBetween", timeBetween, 0 ) if ( count == 1 )
				Kesh::ArgTest::intRage( "timeBetween", timeBetween, 0.05 ) if ( count > 1 )
				Kesh::ArgTest::type( "stateObj", stateObj, Object, true )
				
				timer = TimerCallback.new( self, start, callback, count, timeBetween, stateObj )
				
				Thread.exclusive {
					@heap.add( timer )
				}
				
				wake()				
				return timer
			end	
		
			
			# Remove the given timer, preventing it from being called in the future.
			# Will not remove already-called timers that are waiting as a job on the AsynchWorker.
			def removeTimer( timer )
				Kesh::ArgTest::type( "timer", timer, TimerCallback )
				
				removed = false
				
				Thread.exclusive {
					removed = @heap.removeValue( timer )
				}
				
				return removed
			end
			
		end
		
	end
end							
					