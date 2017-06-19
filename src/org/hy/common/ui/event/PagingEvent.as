package org.hy.common.ui.event
{
	import flash.events.Event;
	
	
	
	/**
	 * 值改变时触发的事件
	 *
	 * @author      ZhengWei(HY)
	 * @createDate  2015-07-08
	 * @version     v1.0
	 */
	public class PagingEvent extends Event
	{
		/**
		 * 事件类常量：此常量的值必须为事件名称才能被自动注册和触发
		 */
		public static const $E_ChangePageNo:String    = "changePageNo";
		
		/**
		 * 动作类型：初始值、未知情况、或用户直接调用 setPageNo 方法
		 */
		public static const $ActionNULL:String        = "NULL";
		
		/**
		 * 动作类型：点击首页按钮的动作
		 */
		public static const $ActionFirstPage:String   = "FirstPage";
		
		/**
		 * 动作类型：点击上一页按钮的动作
		 */
		public static const $ActionUpPage:String      = "UpPage";
		
		/**
		 * 动作类型：点击页号跳转列表的动作
		 */
		public static const $ActionGotoPageNo:String  = "GotoPageNo";
		
		/**
		 * 动作类型：点击下一页按钮的动作
		 */
		public static const $ActionDownPage:String    = "DownPage";
		
		/**
		 * 动作类型：点击尾页按钮的动作
		 */
		public static const $ActionLastPage:String    = "LastPage";
		
		/**
		 * 动作类型：点击更多按钮的动作
		 */
		public static const $ActionMore:String        = "More";
		
		/**
		 * 动作类型：点击全部按钮的动作
		 */
		public static const $ActionAll:String         = "All";
		
		/**
		 * 动作类型：点击刷新按钮的动作
		 */
		public static const $ActionReload:String      = "Reload";
		
		/**
		 * 动作类型：点击每页分页数量按钮的动作
		 */
		public static const $ActionPagePerSize:String = "PagePerSize";
		
		
		
		/** 将要变成新分页的页号 */
		private var _pageNoNew:int;
		
		/** 改变分页页号前的页号 */
		private var _pageNoOld:int;
		
		/** 每页显示记录条数 */
		private var _pagePerSize:int;
		
		/** 动作类型 */
		private var _actionType:String;
		
				
		
		public function PagingEvent(i_Type:String ,i_PageNoNew:int ,i_PageNoOld:int ,i_PagePerSize:int ,i_ActionType:String)
		{
			super(i_Type);
			
			this._pageNoNew   = i_PageNoNew;
			this._pageNoOld   = i_PageNoOld;
			this._pagePerSize = i_PagePerSize;
			
			if ( i_ActionType == null || "" == i_ActionType )
			{
				this._actionType = $ActionNULL;
			}
			else
			{
				this._actionType = i_ActionType;
			}
		}
		
		
		
		override public function clone():Event
		{
			return new PagingEvent(this.type 
				                  ,this._pageNoNew 
								  ,this._pageNoOld 
								  ,this._pagePerSize
			                      ,this._actionType);
		}
		
		
		
		/**
		 * 将要变成新分页的页号
		 */
		public function get pageNoNew():int
		{
			return this._pageNoNew;
		}
		
		
		
		/**
		 * 改变分页页号前的页号
		 */
		public function get pageNoOld():int
		{
			return this._pageNoOld;
		}
		
		
		
		/**
		 * 每页显示记录条数
		 */
		public function get pagePerSize():int
		{
			return this._pagePerSize;
		}
		
		
		
		/**
		 * 动作类型
		 */
		public function get actionType():String
		{
			return this._actionType;
		}
			
	}
}