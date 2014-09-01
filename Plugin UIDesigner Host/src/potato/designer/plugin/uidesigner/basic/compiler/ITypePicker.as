package potato.designer.plugin.uidesigner.basic.compiler
{
	/**
	 * 类型的值选取器
	 * <br>为指定类型注册了值选取器后，在编辑该类型时会显示值选取器。
	 * <br>会在成员视图的当前成员下方显示值选取器。
	 * <br>由于成员视图的宽度为300，所以值选取器宽度建议设为300或者100%。
	 * @author Just4test
	 * 
	 */
	public interface ITypePicker
	{
		/**
		 * 调用此方法后，显示值选取器
		 * <br>如果值选取器是UIComponent，则还会将其添加到
		 * @param memberViewItem 正在编辑的成员
		 * 
		 */
		function show(memberViewItem:MemberViewItem):void;
		
		/**
		 *编辑过程结束，隐藏值选取器 
		 * 
		 */
		function hide():void;
		
		/**
		 *当用户直接在 MemberViewItem中编辑值时，MemberViewItem会调用此方法向值选取器传入当前值。
		 * <br>此接口可能会被频繁调用，其中可能包含大量不合法的值。用户每次击键此接口都会被调用。
		 * @param value 
		 */
		function setValue(value:String):void;
	}
}