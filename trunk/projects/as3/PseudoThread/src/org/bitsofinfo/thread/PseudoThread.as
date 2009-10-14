package org.bitsofinfo.thread {
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * Dispatched when the thread's work is done
	 * 
	 * @eventType	flash.events.Event.COMPLETE
	 */ 
	[Event(name="complete", type="flash.events.Event")]     
	
	/**
	 * Dispatched when the thread encounters an error
	 * or if the Thread times out
	 * 
	 * @eventType	flash.events.ErrorEvent.ERROR
	 */ 
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	/**
	 * Dispatched when the thread's work (IRunnable) makes progress
	 * 
	 * @eventType	flash.events.ErrorEvent.ERROR
	 */ 
	[Event(name="progress", type="flash.events.ProgressEvent")]    
	
	/**
	 * <p>This class simulates a thread in ActionScript </p>
	 * 
	 * <p>You create a PsuedoThread by passing an IRunnable
	 * who's process() function will be called every "msDelay" milliseconds.
	 * The IRunnable's isComplete() method is consulted
	 * after each process() invocation to determine if the processing
	 * should cease. If the IRunnable is NOT completed (and the thread's timeout has not been reached)
	 * PsuedoThread will dispatch ProgressEvents using the progress values retrieved
	 * from IRunnable.getProgress() and IRunnable.getTotal(). 
	 * When IRunnable.isComplete() returns true the Thread will terminate and 
	 * fire off the Event.COMPLETE event. </p>
	 * 
	 * <p>PseudoThreads are useful for time consuming processing operations
	 * where a delay in the UI is un-acceptable. The smaller you set the <code>msDelay</code>
	 * setting, the faster this thread will execute and subsequently other parts of your application
	 * will be less responsive (noteably a GUI).</p>
	 * 
	 * <p>Note! To prevent memory leaks in your application callers must always remember 
	 * to de-register for the complete event from this thread after it has been received
	 *  (as well as the progress and error events!)</p>
	 * 
	 * <P>Caller can also specify the max amount of time this Thread should run before it will 
	 * 	stop processing and throw an Error. This is done via the <code>msTimeout</code> constructor
	 * argument. If no timeout is specified the process will run forever.</P>
	 * 
	 * 
	 * */
	public class PseudoThread extends EventDispatcher {
		
		// the timer which is the core of our PseudoThread
		private var intTimer:Timer = null;
		
		// total times we have ran
		private var totalTimesRan:int = 0;
		
		// default max runtimes is forever
		private var maxRunTimes:int = 0;
		
		// the IRunnable we are processing
		private var runnable:IRunnable = null;
		
		// a unique name for me
		private var myName:String;

			
		
		/**
		 * Constructor. 
		 * 
		 * @param	runnable			The IRunnable that this thread will process. The IRunnable's process()
		 * 								method will be called repeatably by this thread.
		 * 
		 * @param	threadName			a name identifier
		 * 
		 * @param	msDelay				delay between each thread "execution" call of IRunnable.process(), in milliseconds
		 * 
		 * @param	msTimeout			the max amount of time this PseudoThread should run before it will 
		 * 								stop processing and dispatch an ErrorEvent. If no timeout is specified
		 * 								the process will run until the IRunnable reports that it is complete.
		 * 
		 * */
		public function PseudoThread(runnable:IRunnable, threadName:String, msDelay:Number=200, msTimeout:Number=-1) {
			this.myName = threadName;
			this.runnable = runnable;

			if (msTimeout != -1) {
				if (msTimeout < msDelay) {
					throw new Error("PseudoThread cannot be constructed with a msTimeout that is less than the msDelay");
				}
				maxRunTimes = Math.ceil(msTimeout / msDelay);
			}

			this.intTimer = new Timer(msDelay,maxRunTimes);
			this.intTimer.addEventListener(TimerEvent.TIMER,processor);
		}
		

		
		/** 
		 * Destroys this and deregisters from the Timer event
		 * */
		public function destroy():void {
			this.intTimer.stop();
			this.intTimer.removeEventListener(TimerEvent.TIMER,processor);
			this.runnable = null;
			this.intTimer = null;
		}

		/**
		 * Called each time our internal Timer executes. Here we call the runnable's process() function 
		 * and then check the IRunnable's state to see if we are done. If we are done we dispatch a complete
		 * event. If progress is made we dispatch progress, lastly on error, this will destroy itself 
		 * and dispatch an ErrorEvent.<BR><BR>
		 * 
		 * Note that an ErrorEvent will be thrown if a timeout was specified and we have reached it without
		 * the IRunnable reporting isComplete() within the timeout period.
		 * 
		 * @throws ErrorEvent when the process() method encounters an error or if the timeout is reached.
		 * @param	e TimerEvent
		 * */
		private function processor(e:TimerEvent):void {
			try {
				this.runnable.process();
				this.totalTimesRan++;
				
			} catch(e:Error) {
				destroy();
				this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"PsuedoThread ["+this.myName+"] encountered an error while" + 
						" calling the IRunnable.process() method: " +e.message));
				return;
			}
			
			if (runnable.isComplete()) {
				this.dispatchEvent(new Event(Event.COMPLETE,false,false));
				destroy();
			} else {
				
				if (this.maxRunTimes != 0 && this.maxRunTimes == this.totalTimesRan) {
					destroy();
					this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"PsuedoThread ["+this.myName+"] " + 
							"timeout exceeded before IRunnable reported complete"));
					return;
					
				} else {
					this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,false,false,runnable.getProgress(),runnable.getTotal()));
				}
			}
		}

		/**
		 * This method should be called when the thread is to start running and calling
		 * it's IRunnable's process() method until work is finished.
		 * 
		 * */
		public function start():void {
			this.intTimer.start(); 
		}

	}
}