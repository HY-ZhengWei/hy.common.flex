package org.hy.common
{
	/**
	 * 等待执行的条件，当所有条件都满足后才执行指定的动作
	 * 
	 * @author      ZhengWei(HY)
	 * @createDate  2015-10-30
	 * @version     v1.0
	 */
	public class WaitExecute
	{
		/** 默认初始状态。表示：什么都不做，不用等待 */
		public static const $NULL   :int = -1;
		
		/** 等待中 */
		public static const $Waiting:int = 0;
		
		/** 执行完成 */
		public static const $Finish :int  = 1;
		
		
		
		/** 所有条件都满足后才执行的动作  */
		private var _action:Function;
		
		/** 执行动作的调用者 */
		private var _actionObject:*;
		
		/** 执行动作的入参参数  */
		private var _actionParams:*;
		
		/** 所有条件都满足后，是否自动执行指定的动作 */
		private var _isAutoExecute:Boolean;
		
		/** 第三方自行定义的标记名称对应的"等待状态值" */
		private var _flagValues:Object;

		
		
		public function WaitExecute(i_Action:Function ,i_ActionObject:*=null ,i_ActionParams:*=null)
		{
			this._action        = i_Action;
			this._actionObject  = i_ActionObject
			this._actionParams  = i_ActionParams;
			this._isAutoExecute = true;
			this._flagValues    = new Object();
		}
		
		
		
		/**
		 * 添加某一条件，并设置为"等待"状态
		 */
		public function conditionWaiting(...i_FlagIDs):WaitExecute
		{
			if ( i_FlagIDs == null )
			{
				return this;
			}
			
			for (var v_Index:int=0; v_Index<i_FlagIDs.length; v_Index++)
			{
				if ( i_FlagIDs[v_Index] == null )
				{
					continue;
				}
				
				var v_FlagID:String = i_FlagIDs[v_Index].toString();
				if ( Help.isNull(v_FlagID) || this._flagValues.hasOwnProperty(Help.trim(v_FlagID)) )
				{
					// 不能重复添加
					continue;
				}
				
				this._flagValues[Help.trim(v_FlagID)] = $Waiting;
			}
			
			return this;
		}
		
		
		
		/**
		 * 标记某一条件已"完成"，即此条件已"满足"
		 * 
		 * 同时，会检查所条件是否都"满足"了，都满足就执行指定的动作
		 */
		public function conditionFinish(...i_FlagIDs):WaitExecute
		{
			if ( i_FlagIDs == null )
			{
				return this;
			}
			
			for (var v_Index:int=0; v_Index<i_FlagIDs.length; v_Index++)
			{
				if ( i_FlagIDs[v_Index] == null )
				{
					continue;
				}
				
				var v_FlagID:String = i_FlagIDs[v_Index].toString();
				if ( Help.isNull(v_FlagID) || !this._flagValues.hasOwnProperty(Help.trim(v_FlagID)) )
				{
					continue;
				}
				
				this._flagValues[Help.trim(v_FlagID)] = $Finish;
				
				if ( this._isAutoExecute )
				{
					this.checkExecute();
				}
			}
			
			return this;
		}
		
		
		
		/**
		 * 检查条件是否都满足
		 */
		public function check():Boolean
		{
			for each (var v_PValue:int in this._flagValues)
			{
				if ( v_PValue == $Waiting )
				{
					return false;
				}
			}
			
			return true;
		}
		
		
		
		/**
		 * 检查条件都满足后，执行指定的动作
		 */
		public function checkExecute():*
		{
			if ( this.check() )
			{
				return this.execute();
			}
			
			return null;
		}
		
		
		
		/**
		 * 执行动作
		 */
		public function execute():*
		{
			if ( this._action != null )
			{
				return this._action.apply(this._actionObject ,this._actionParams);
			}
			
			return null;
		}
		
		
		
		/** 
		 * 所有条件都满足后才执行的动作 
		 */
		public function get action():Function
		{
			return _action;
		}
		
		
		
		/** 
		 * 执行动作的调用者 
		 */
		public function get actionObject():*
		{
			return _actionObject;
		}
		
		
		
		/** 
		 * 执行动作的入参参数  
		 */
		public function get actionParams():*
		{
			return _actionParams;
		}
		
		
		
		/** 
		 * 所有条件都满足后，是否自动执行指定的动作
		 */
		public function get isAutoExecute():Boolean
		{
			return _isAutoExecute;
		}

		
		
		/** 
		 * 所有条件都满足后，是否自动执行指定的动作 
		 */
		public function set isAutoExecute(value:Boolean):void
		{
			_isAutoExecute = value;
		}
		
	}
	
}