package potato.utils
{
	import potato.events.IEventDispatcher;

	public interface ILogin extends IEventDispatcher
	{
		/**
		 * @eventType sf.events.LoginEvent.LOGIN_SUCCESS
		 */	
		[Event(name="login_success",type="sf.events.LoginEvent")]
		
		/**
		 * @eventType sf.events.LoginEvent.LOGIN_ERROR
		 */	
		[Event(name="login_error",type="sf.events.LoginEvent")]
		
		/**
		 * @eventType sf.events.LoginEvent.LOGIN_OUT
		 */	
		[Event(name="login_out",type="sf.events.LoginEvent")]
		
		/**
		 * @eventType sf.events.LoginEvent.LOGIN_CANCEL
		 */	
		[Event(name="login_cancel",type="sf.events.LoginEvent")]
		
		
		function login():void;
		
		function logout():void;
	}
}