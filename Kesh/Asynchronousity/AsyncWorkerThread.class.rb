requireLibrary '../../Asynchronousity'
requireClass 'ThreadControl'

module Kesh
	module Asynchronousity
	
		# Used by the AsyncWorker to complete jobs.
		class AsyncWorkerThread < ThreadControl
		
			# Initialize our worker thread.
			def initialize( worker )
				Kesh::ArgTest::type( "worker", worker, AsyncWorker )
				@worker = worker
				@job = nil
			end
			

			protected
			def stopping?()
				return true if ( @stop )
				@job = @worker.getNextJob()
				return ( @job == nil )
			end
			
			
			def notStopping()
				@job.work()
			end
			
		end
		
	end
end		
