package org.bitsofinfo.thread {
	
	/**
	 * An IRunnable is to be used with PseudoThread which
	 * will call an IRunnable's process() method repeatedly
	 * until a timeout is reached or the isComplete() method returns
	 * true.
	 * 
	 * @see PseudoThread
	 * 
	 * */
	public interface IRunnable {
		
		/**
		 * Called repeatedly by PseudoThread until
		 * a timeout is reached or isComplete() returns true.
		 * Implementors should implement their functioning
		 * code that does actual work within this method
		 * 
		 * */
		function process():void;
		
		/**
		 * Called by PseudoThread after each successful call
		 * to process(). Once this returns true, the thread will
		 * stop.
		 *
		 * @return	boolean	true/false if the work is done and no further
		 * 			calls to process() should be made
		 * */
		function isComplete():Boolean;
		
		/**
		 * Returns an int which represents the total
		 * amount of "work" to be done.
		 * 
		 * @return	int	total amount of work to be done
		 * */
		function getTotal():int;
		
		/**
		 * Returns an int which represents the total amount
		 * of work processed so far out of the overall total
		 * returned by getTotal()
		 * 
		 * @return	int	total amount of work processed so far
		 * */
		function getProgress():int;
		
		
	}
	
}