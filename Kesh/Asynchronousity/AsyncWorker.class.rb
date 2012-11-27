requireLibrary '../../Asynchronousity'

module Kesh
	module Asynchronousity
	
		# A class that uses multiple threads and a queue system to handle jobs.
		class AsyncWorker
		
			# Status of the worker threads.
			#
			# * :worker_status_idle
			# * :worker_status_working
			attr_reader :status
		
			# Initialize our worker with the given number of worker threads.
			def initialize( workerCount )
				Kesh::ArgTest::type( "workerCount", workerCount, Fixnum )
				Kesh::ArgTest::intRange( "workerCount", workerCount, 1, 99 ) # lots of threads...
				
				@workers = []
				@jobs = []
				@status = :worker_status_idle
				
				[0..workerCount].each do |i|
					@workers[ i ] = AsyncWorkerThread.new( self )
				end
			end
			
			
			# Start processing jobs.
			def start()
				return false unless ( @status == :worker_status_idle )
				
				Thread.exclusive {
					@workers.each do |w|
						w.start()
					end
					
					@status = :worker_status_working
				}
				
				return true
			end
			
			
			# Poke a worker with a stick to wake it up, so it can start processing jobs.
			def wake()
				Thread.exlusive {
					@workers.each do |w|
						break if w.wake()
					end
				}
			end
		
			
			# Stop the workers processing jobs.  Vive la resistance!
			def stop()
				return false unless ( @status == :worker_status_working )
				
				Thread.exclusive {
					@workers.each do |w|
						w.stop()
					end
					
					@status = :worker_status_idle
				}
				
				return true
			end	
			
			
			# Add a job to be executed.
			def addJob( job )
				Thread.exclusive {
					@jobs << job
					wake()
				}
			end
			
			
			# Stop a job from being executed.
			def cancelJob( job )
				cancelled = false
				
				Thread.exclusive {
					cancelled =  ( @jobs.delete( job ) != nil )
				}					
				
				return cancelled
			end
			
			
			# Get the next job to be executed.  Called by the worker threads.
			def getNextJob()
				job = nil
				
				Thread.exclusive {
					i = @jobs.index { |j| j.canStart() }
					job = @jobs.delete_at( i ) if ( i != nil )
				}
				
				return job
			end
			
		end
		
	end
end
	