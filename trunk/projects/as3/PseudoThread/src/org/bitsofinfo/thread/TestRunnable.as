package org.bitsofinfo.thread
{

	public class TestRunnable implements IRunnable
	{
		
		private var counter:int = 0;
		private var totalToReach:int = 100;
		
		public function TestRunnable() {
			
		}

		public function process():void {
			counter++;
		}
		
		public function isComplete():Boolean {
			return counter == totalToReach;
		}
		
		public function getTotal():int
		{
			return this.totalToReach;
		}
		
		public function getProgress():int
		{
			return this.counter;
		}
		
	}
}