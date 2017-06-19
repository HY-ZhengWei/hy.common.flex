package org.hy.common.ui
{
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.hy.common.Help;
	import org.hy.common.skins.spark.TextInputDoubleSkin;
	import org.hy.common.ui.event.EventInfo;
	import org.hy.common.ui.event.FocusEventTrue;
	
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;
	
	
	
	[DefaultProperty("text")]
	
	[DefaultTriggerEvent("change")]
	
	/**
	 * 同时装载两种信息的文本框。
	 *   当为数字时，this.text = 1.23456789 时，当文本框没有获取焦点时，默认只显示为：1.235
	 *   当为文字时，this.text = ABCDEFGHIJ 时，两种信息是一样的。
	 * 
	 *   它还有多种附加信息，提供给外界保存数据。
	 * 
	 *  建议为数字文本框时设置属性 restrict="0-9\-\.eE"
	 * 
	 * @author      ZhengWei(HY)
	 * @createDate  2016-08-25
	 * @version     V1.0
	 * @version     V2.0  2016-11-23  发现TextInputDouble_V1存在严重的Bug，固弃之。
	 *                                Bug：当鼠标点击进入文本框时（TextInputDouble_V1整体获取焦点时），
	 *                                     会触发两次焦点进入事件 FocusEvent.FOCUS_IN ，
	 *                                     同时，在两次焦点进入事件的中间，还会触发一次焦点离开事件 FocusEvent.FOCUS_OUT 。
	 * 
	 *              V3.0  2016-11-24  通过自定义焦点事件的方式，提供给外界最靠谱的焦点进入(或离开)事件，间接的解决上面的Bug。
	 *              V4.0  2017-02-23  添加 FocusEvent.KEY_FOCUS_CHANGE 事件的监听。键盘改变焦点的事件。如 Tab键快速切换焦点。
	 *                                两个控制焦点的变量进行设定。防止界面不正确的显示。
	 *              V5.0  2017-03-15  添加 FocusEvent.MOUSE_FOCUS_CHANGE 事件的监听。先键盘后鼠标改变焦点时（或先鼠标后键盘），的鼠标改变焦点的事件。
	 *                                两个控制焦点的变量进行设定。防止界面不正确的显示。
	 */
	[Event(name="focusInTrue"  ,type="org.hy.common.ui.event.FocusEventTrue")]
	[Event(name="focusOutTrue" ,type="org.hy.common.ui.event.FocusEventTrue")]
	public class TextInputDouble extends spark.components.TextInput
	{
		
		/** 最原始外界设置的文本值 */
		private var _textOriginal:String;
		
		/** 真实文本的四舍五入的精度（默认为：9） */
		private var _roundDouble:uint;
		
		/** 用于显示的四舍五入的精度（默认为：3） */
		private var _roundShow:uint;
		
		/** 科学计数法下的四舍五入的精度（默认为：3） */
		private var _roundScientific:uint;
		
		
		
		
		/** 焦点是否有效 */
		private var _focusIsValid:Boolean;
		
		/** 焦点进入的次数 */
		private var _focusInCount:int;
		
		/** 焦点离开的次数 */
		private var _focusOutCount:int;
		
		
		
		/** 内嵌皮肤 */
		private var _hSkin:TextInputDoubleSkin;
		
		/** 顶部左边的提示三角形 */
		private var _hintTopLeftVisible:Boolean;
		
		/** 顶部右边的提示三角形 */
		private var _hintTopRightVisible:Boolean;
		
		/** 底部左边的提示三角形 */
		private var _hintBottomLeftVisible:Boolean;
		
		/** 底部右边的提示三角形 */
		private var _hintBottomRightVisible:Boolean;
		
		
		/** 顶部左边的提示三角形的颜色 */
		private var _hintTopLeftColor:uint;
		
		/** 顶部右边的提示三角形的颜色 */
		private var _hintTopRightColor:uint;
		
		/** 底部左边的提示三角形的颜色 */
		private var _hintBottomLeftColor:uint;
		
		/** 底部右边的提示三角形的颜色 */
		private var _hintBottomRightColor:uint;
		
		
		/** 绘制三角形的大小 */
		private var _hintSize:uint;
		
		
		/** 附加的信息（不在界面上显示）。由外界自定义使用。可为空。*/
		private var _textHide:String;
		
		/** 附加的逻辑值（不在界面上显示）。由外界自定义使用。可为空。*/
		private var _textHideBool:Boolean;
		
		/** 附加的数值（不在界面上显示）。由外界自定义使用。可为空。*/
		private var _textHideNum:Number;
		
		/** 附加的时间（不在界面上显示）。由外界自定义使用。可为空。*/
		private var _textHideTime:Date;
		
		/** 附加的对象（不在界面上显示）。由外界自定义使用。可为空。*/
		private var _textHideObj:Object;
		
		
        
        /** 负责编辑文本框是否启用延时添加事件监听的功能 */
        private var _isDelayByText:Boolean = true;
		
		/** 负责显示文本框是否启用延时添加事件监听的功能 */
		private var _isDelayByShow:Boolean = false;
		
		/** 负责编辑文本框的延时添加事件监听的事件缓存 */
		private var _textEventInfos:ArrayCollection = new ArrayCollection();
		
		/** 负责显示文本框的延时添加事件监听的事件缓存 */
		private var _showEventInfos:ArrayCollection = new ArrayCollection();
		
		
		
		public function TextInputDouble()
		{
			super();
			
			this._roundDouble     = 9;
			this._roundShow       = 3;
			this._roundScientific = 3;
			this._focusIsValid    = true;
			this._focusInCount    = 0;
			this._focusOutCount   = 0;
			
			this._textHide        = null;
			this._textHideBool    = false;
			this._textHideNum     = 0;
			this._textHideTime    = null;
			this._textHideObj     = null;
			
			this.addEventListener(FlexEvent.INITIALIZE ,InitializeHandler);
			this.setStyle('skinClass' ,TextInputDoubleSkin);
			
			this._hintTopLeftVisible     = false;
			this._hintTopRightVisible    = false;
			this._hintBottomLeftVisible  = false;
			this._hintBottomRightVisible = false;
			
			this._hintTopLeftColor     = Help.toColor("0xFF4444");
			this._hintTopRightColor    = Help.toColor("0xFF4444");
			this._hintBottomLeftColor  = Help.toColor("0xFF4444");
			this._hintBottomRightColor = Help.toColor("0xFF4444");
			
			this._hintSize             = 8;
		}
		
		
		
		protected function InitializeHandler(event:FlexEvent):void
		{
			this._hSkin = this.skin as TextInputDoubleSkin;
			
			this.InitializeAddEvents();
			
			this.addEventListener(FocusEvent.FOCUS_IN           ,FocusInHandler);
			this.addEventListener(FocusEvent.FOCUS_OUT          ,FocusOutHandler);
			this.addEventListener(FocusEvent.KEY_FOCUS_CHANGE   ,KeyFocusChangeHandler);
			this.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE ,MouseFocusChangeHandler);
			this.addEventListener(TextOperationEvent.CHANGE     ,ChangeHandler);
			
			this._hSkin.hintTopLeft    .visible = this._hintTopLeftVisible;
			this._hSkin.hintTopRight   .visible = this._hintTopRightVisible;
			this._hSkin.hintBottomLeft .visible = this._hintBottomLeftVisible;
			this._hSkin.hintBottomRight.visible = this._hintBottomRightVisible;
			
			this._hSkin.hintTopLeftColor        = this._hintTopLeftColor;
			this._hSkin.hintTopRightColor       = this._hintTopRightColor;
			this._hSkin.hintBottomLeftColor     = this._hintBottomLeftColor;
			this._hSkin.hintBottomRightColor    = this._hintBottomRightColor;
			
			this._hSkin.hintSize                = this._hintSize;
			
			this.setShowText();
		}
		
		
		
		/**
		 * 将所有延时添加的事件，添加监听。添加后将删除缓存中的所有事件。
		 */
		private function InitializeAddEvents():void
		{
			if ( this._hSkin == null )
			{
				return;
			}
			
			var v_Index:int = -1;
			var v_EventInfo:EventInfo = null;
			
			if ( !Help.isNull(this._textEventInfos) )
			{
				for (v_Index=this._textEventInfos.length-1; v_Index>=0; v_Index--)
				{
					v_EventInfo = this._textEventInfos.removeItemAt(v_Index) as EventInfo;
					
					this._hSkin.textDisplay.addEventListener(v_EventInfo.type
						                                    ,v_EventInfo.listener
															,v_EventInfo.useCapture
															,v_EventInfo.priority
															,v_EventInfo.useWeakReference);
				}
			}
			
			if ( !Help.isNull(this._showEventInfos) )
			{
				for (v_Index=this._showEventInfos.length-1; v_Index>=0; v_Index--)
				{
					v_EventInfo = this._showEventInfos.removeItemAt(v_Index) as EventInfo;
					
					this._hSkin.m_ShowText.addEventListener(v_EventInfo.type
						                                   ,v_EventInfo.listener
						                                   ,v_EventInfo.useCapture
						                                   ,v_EventInfo.priority
						                                   ,v_EventInfo.useWeakReference);
				}
			}
		}
		
		
		
		/**
		 * 对焦点离开监听事件特殊处理，防止 this.hSkin.m_ShowText 与 this._hSkin.textDisplay 相互切换显示时，两次触发 “焦点离开事件”  ZhengWei(HY) Add 2016-11-23
		 */
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if ( this._isDelayByText && type == FocusEvent.FOCUS_OUT )
			{
				if ( this._hSkin != null )
				{
					this._hSkin.textDisplay.addEventListener(type, listener, useCapture, priority, useWeakReference);
				}
				else
				{
					this._textEventInfos.addItem(new EventInfo(type ,listener ,useCapture ,priority ,useWeakReference));
				}
			}
			else if ( this._isDelayByShow && type == FocusEvent.FOCUS_IN )
			{
				if ( this._hSkin != null )
				{
					this._hSkin.m_ShowText.addEventListener(type, listener, useCapture, priority, useWeakReference);
				}
				else
				{
					this._showEventInfos.addItem(new EventInfo(type ,listener ,useCapture ,priority ,useWeakReference));
				}
			}
			else
			{
				super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		
		
		
		/**
		 * 对焦点离开监听事件特殊处理，防止 this.hSkin.m_ShowText 与 this._hSkin.textDisplay 相互切换显示时，两次触发 “焦点离开事件”  ZhengWei(HY) Add 2016-11-23
		 */
		override public function hasEventListener(type:String):Boolean
		{
			var v_Index:int = -1;
			var v_EventInfo:EventInfo = null;
			
			if ( this._isDelayByText && type == FocusEvent.FOCUS_OUT )
			{
				if ( this._hSkin != null )
				{
					return this._hSkin.textDisplay.hasEventListener(type);
				}
				else
				{
					if ( Help.isNull(this._textEventInfos) )
					{
						return false;
					}
					
					for (v_Index=this._textEventInfos.length-1; v_Index>=0; v_Index--)
					{
						v_EventInfo = this._textEventInfos.getItemAt(v_Index) as EventInfo;
						
						if ( v_EventInfo.type == type )
						{
							return true;
						}
					}
					
					return false;
				}
			}
			else if ( this._isDelayByShow && type == FocusEvent.FOCUS_IN )
			{
				if ( this._hSkin != null )
				{
					return this._hSkin.m_ShowText.hasEventListener(type);
				}
				else
				{
					if ( Help.isNull(this._showEventInfos) )
					{
						return false;
					}
					
					for (v_Index=this._showEventInfos.length-1; v_Index>=0; v_Index--)
					{
						v_EventInfo = this._showEventInfos.getItemAt(v_Index) as EventInfo;
						
						if ( v_EventInfo.type == type )
						{
							return true;
						}
					}
					
					return false;
				}
			}
			else
			{
				return super.hasEventListener(type);
			}
		}
		
		
		
		/**
		 * 对焦点离开监听事件特殊处理，防止 this.hSkin.m_ShowText 与 this._hSkin.textDisplay 相互切换显示时，两次触发 “焦点离开事件”  ZhengWei(HY) Add 2016-11-23
		 */
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			var v_Index:int = -1;
			var v_EventInfo:EventInfo = null;
			
			if ( this._isDelayByText && type == FocusEvent.FOCUS_OUT )
			{
				if ( this._hSkin != null )
				{
					this._hSkin.textDisplay.removeEventListener(type, listener, useCapture);
				}
				else
				{
					if ( Help.isNull(this._textEventInfos) )
					{
						return;
					}
					
					for (v_Index=this._textEventInfos.length-1; v_Index>=0; v_Index--)
					{
						v_EventInfo = this._textEventInfos.getItemAt(v_Index) as EventInfo;
						
						if ( v_EventInfo.type       == type 
						  && v_EventInfo.listener   == listener 
						  && v_EventInfo.useCapture == useCapture )
						{
							this._textEventInfos.removeItemAt(v_Index);
							return;
						}
					}
				}
			}
			else if ( this._isDelayByShow && type == FocusEvent.FOCUS_IN )
			{
				if ( this._hSkin != null )
				{
					this._hSkin.m_ShowText.removeEventListener(type, listener, useCapture);
				}
				else
				{
					if ( Help.isNull(this._showEventInfos) )
					{
						return;
					}
					
					for (v_Index=this._showEventInfos.length-1; v_Index>=0; v_Index--)
					{
						v_EventInfo = this._showEventInfos.getItemAt(v_Index) as EventInfo;
						
						if ( v_EventInfo.type       == type 
						  && v_EventInfo.listener   == listener 
						  && v_EventInfo.useCapture == useCapture )
						{
							this._showEventInfos.removeItemAt(v_Index);
							return;
						}
					}
				}
			}
			else
			{
				super.removeEventListener(type, listener, useCapture);
			}
		}
		
		
		
		/**
		 * 对焦点离开监听事件特殊处理，防止 this.hSkin.m_ShowText 与 this._hSkin.textDisplay 相互切换显示时，两次触发 “焦点离开事件”  ZhengWei(HY) Add 2016-11-23
		 */
		override public function willTrigger(type:String):Boolean
		{
			var v_Index:int = -1;
			var v_EventInfo:EventInfo = null;
			
			if ( this._isDelayByText && type == FocusEvent.FOCUS_OUT )
			{
				if ( this._hSkin != null )
				{
					return this._hSkin.textDisplay.willTrigger(type);
				}
				else
				{
					if ( Help.isNull(this._textEventInfos) )
					{
						return false;
					}
					
					for (v_Index=this._textEventInfos.length-1; v_Index>=0; v_Index--)
					{
						v_EventInfo = this._textEventInfos.getItemAt(v_Index) as EventInfo;
						
						if ( v_EventInfo.type == type )
						{
							return true;
						}
					}
					
					return false;
				}
			}
			else if ( this._isDelayByShow && type == FocusEvent.FOCUS_IN )
			{
				if ( this._hSkin != null )
				{
					return this._hSkin.m_ShowText.willTrigger(type);
				}
				else
				{
					if ( Help.isNull(this._showEventInfos) )
					{
						return false;
					}
					
					for (v_Index=this._showEventInfos.length-1; v_Index>=0; v_Index--)
					{
						v_EventInfo = this._showEventInfos.getItemAt(v_Index) as EventInfo;
						
						if ( v_EventInfo.type == type )
						{
							return true;
						}
					}
					
					return false;
				}
			}
			else
			{
				return super.willTrigger(type);
			}
		}
		
		
		
		protected function FocusInHandler(i_Event:FocusEvent):void
		{
			this._focusInCount++;
			
			if ( this._focusInCount % 2 == 0 )
			{
				return;
			}
			else
			{
				this.hideText();
				
				// ZhengWei(HY) Add 2016-11-24
				// 这个IF判断不是多余，它是会被成功执行的。
				// 因为 this.hideText() 方法中的 this._hSkin.textDisplay.setFocus() 会再一次以递归的方式触发焦点进入事件。
				// 所以，当 this.hideText() 真正执行完成时，this._focusInCount++ 它已执行了两次。
				if ( this._focusInCount % 4 == 0 )
				{
					this.dispatchEvent(new FocusEventTrue(FocusEventTrue.FOCUS_IN ,i_Event));
				}
			}
		}
		
		
		
		protected function FocusOutHandler(i_Event:FocusEvent):void
		{
			this._focusOutCount++;
			
			if ( this._focusOutCount % 2 == 1 )
			{
				return;
			}
			else
			{
				this.showText();
				this.dispatchEvent(new FocusEventTrue(FocusEventTrue.FOCUS_OUT ,i_Event));
			}
		}
		
		
		
		/**
		 * 键盘改变焦点的事件。如 Tab键快速切换焦点  ZhengWei(HY) Add 2017-02-23
		 * 
		 * 此事件触发后，回根据实际情况再触发 FocusEvent.FOCUS_IN 或 FocusEvent.FOCUS_OUT 事件。
		 * 
		 * 所以，对两个控制焦点的变量进行设定。防止界面不正确的显示。
		 */
		protected function KeyFocusChangeHandler(i_Event:FocusEvent):void
		{
			if ( null != this._hSkin && null != this._hSkin.m_ShowText )
			{
				if ( this._hSkin.textDisplay.visible )
				{
					this._focusInCount  = 0;
					this._focusOutCount = -1;
				}
				else
				{
					this._focusInCount  = -1;
					this._focusOutCount = 0;
				}
			}
		}
		
		
		
		/**
		 * 先键盘后鼠标改变焦点时（或先鼠标后键盘），的鼠标改变焦点的事件。 ZhengWei(HY) Add 2017-03-15
		 * 
		 * 此事件触发后，回根据实际情况再触发 FocusEvent.FOCUS_IN 或 FocusEvent.FOCUS_OUT 事件。
		 * 
		 * 所以，对两个控制焦点的变量进行设定。防止界面不正确的显示。
		 */
		protected function MouseFocusChangeHandler(i_Event:FocusEvent):void
		{
			if ( null != this._hSkin && null != this._hSkin.m_ShowText )
			{
				if ( this._hSkin.textDisplay.visible )
				{
					this._focusInCount  = 0;
					this._focusOutCount = -1;
				}
				else
				{
					this._focusInCount  = -1;
					this._focusOutCount = 0;
				}
			}
		}
		
		
		
		protected function ChangeHandler(event:TextOperationEvent):void
		{
			this._textOriginal = super.text;
		}
		
		
		
		[Bindable("change")]
		[Bindable("textChanged")]
		[CollapseWhiteSpace]
		override public function set text(i_Value:String):void
		{
			this._textOriginal = i_Value;
			this.setText(i_Value);
		}
		
		
		
		/**
		 * 设置文本的值。
		 * 当小于指定范围时，自动转为科学计数
		 */
		protected function setText(i_Value:String):void
		{
			if ( this._hSkin != null && this._hSkin.textDisplay.visible )
			{
				super.text = i_Value;
			}
			else
			{
				try
				{
					var v_Num:Number = Help.toNumber(i_Value);
					
					if ( isNaN(v_Num) )
					{
						super.text = i_Value;
					}
					else
					{
						super.text = Help.toScientificNotation(v_Num ,this._roundShow + 1 ,this._roundScientific ,this._roundDouble);
					}
				}
				catch (error:Error)
				{
					super.text = i_Value;
				}
			}
			
			this.setShowText();
		}
		
		
		
		protected function setShowText():void
		{
			if ( this._hSkin == null )
			{
				return;	
			}
			
			if ( Help.isNull(this.text) )
			{
				this._hSkin.m_ShowText.text = this.text;
			}
			else
			{
				if ( !this._hSkin.textDisplay.visible )
				{
					try
					{
						var v_NumText:Number = Help.toNumber(this.text);
						
						if ( !isNaN(v_NumText) )
						{
							super.text = Help.toScientificNotation(v_NumText ,this._roundShow + 1 ,this._roundScientific ,this._roundDouble);
						}
					}
					catch (error:Error)
					{
						// Nothing
					}
				}
				
				try
				{
					var v_Num:Number = Help.toNumber(this.text);
					
					if ( isNaN(v_Num) )
					{
						this._hSkin.m_ShowText.text = this.text;	
					}
					else
					{
						var v_TempText:String = Help.toFixed(v_Num ,this._roundShow);
						this._hSkin.m_ShowText.text = this.text.length <= v_TempText.length ? this.text : v_TempText;
					}
				}
				catch (error:Error)
				{
					this._hSkin.m_ShowText.text = this.text;
				}
			}
		}
		
		
		
		protected function showText():void
		{
			if ( null != this._hSkin && null != this._hSkin.m_ShowText )
			{
				// trace(this.id + "  FocusOutHandler ......." + (new Date()).toString());
				
				this._hSkin.m_ShowText .visible = true;
				this._hSkin.textDisplay.visible = false;
				
				this.setShowText();
			}
		}
		
		
		
		protected function hideText():void
		{
			if ( null != this._hSkin && null != this._hSkin.m_ShowText )
			{
				// trace(this.id + "  FocusInHandler ......." + (new Date()).toString());
				
				this._hSkin.textDisplay.visible = true;
				this._hSkin.m_ShowText .visible = false;
				this._hSkin.textDisplay.setFocus();
			}
		}
		
		
		
		/** 四舍五入的精度（默认为：3） */
		[Bindable]
		public function get roundShow():uint
		{
			return _roundShow;
		}
		
		public function set roundShow(i_RoundShow:uint):void
		{
			this._roundShow = i_RoundShow;
		}

		
		
		/** 科学计数法下的四舍五入的精度（默认为：5） */
		[Bindable]
		public function get roundScientific():uint
		{
			return _roundScientific;
		}
		
		public function set roundScientific(value:uint):void
		{
			this._roundScientific = value;
			this.setText(this._textOriginal);
		}
		
		
		
		/** 获取显示的文本信息 */
		public function get textShow():String
		{
			if ( this._hSkin == null )
			{
				return super.text;	
			}
			else
			{
				return this._hSkin.m_ShowText.text;
			}
		}

		
		
		/** 最原始外界设置的文本值 */
		public function get textOriginal():String
		{
			return _textOriginal;
		}

		
		
		/** 真实文本的四舍五入的精度（默认为：9） */
		[Bindable]
		public function get roundDouble():uint
		{
			return _roundDouble;
		}

		public function set roundDouble(value:uint):void
		{
			_roundDouble = value;
		}
		
		
		
		/**
		 * 设置所有提示是否显示或隐藏
		 */
		public function set hintAllVisible(i_Visible:Boolean):void
		{
			this._hintTopLeftVisible     = i_Visible;
			this._hintTopRightVisible    = i_Visible;
			this._hintBottomLeftVisible  = i_Visible;
			this._hintBottomRightVisible = i_Visible;
			
			if ( null == this._hSkin )
			{
				return;
			}
			this._hSkin.hintAllVisible = i_Visible;
		}
		
		
		
		/**
		 * 设置所有提示的颜色
		 */
		public function set hintAllColor(i_Color:uint):void
		{
			this._hintTopLeftColor     = i_Color;
			this._hintTopRightColor    = i_Color;
			this._hintBottomLeftColor  = i_Color;
			this._hintBottomRightColor = i_Color;
			
			if ( null == this._hSkin )
			{
				return;
			}
			this._hSkin.hintAllColor = i_Color;
		}
		
		
		
		[Bindable]
		public function get hintSize():uint
		{
			if ( null == this._hSkin )
			{
				return this._hintSize;
			}
			return this._hSkin.hintSize;
		}
		
		public function set hintSize(i_HintSize:uint):void
		{
			this._hintSize = i_HintSize;
			
			if ( null == this._hSkin )
			{
				return;
			}
			this._hSkin.hintSize = i_HintSize;
		}
		
		
		
		[Bindable]
		public function get hintTopLeftVisible():Boolean
		{
			if ( null == this._hSkin )
			{
				return false;
			}
			return this._hSkin.hintTopLeft.visible;
		}
		
		public function set hintTopLeftVisible(i_Visible:Boolean):void
		{
			this._hintTopLeftVisible = i_Visible;
			
			if ( null == this._hSkin )
			{
				return;
			}
			this._hSkin.hintTopLeft.visible = i_Visible;
		}
		
		
		
		[Bindable]
		public function get hintTopRightVisible():Boolean
		{
			if ( null == this._hSkin )
			{
				return false;
			}
			return this._hSkin.hintTopRight.visible;
		}
		
		public function set hintTopRightVisible(i_Visible:Boolean):void
		{
			this._hintTopRightVisible = i_Visible;
			
			if ( null == this._hSkin )
			{
				return;
			}
			this._hSkin.hintTopRight.visible = i_Visible;
		}
		
		
		
		[Bindable]
		public function get hintBottomLeftVisible():Boolean
		{
			if ( null == this._hSkin )
			{
				return false;
			}
			return this._hSkin.hintBottomLeft.visible;
		}
		
		public function set hintBottomLeftVisible(i_Visible:Boolean):void
		{
			this._hintBottomLeftVisible = i_Visible;
			if ( null == this._hSkin )
			{
				return;
			}
			this._hSkin.hintBottomLeft.visible = i_Visible;
		}
		
		
		
		[Bindable]
		public function get hintBottomRightVisible():Boolean
		{
			if ( null == this._hSkin )
			{
				return false;
			}
			return this._hSkin.hintBottomRight.visible;
		}
		
		public function set hintBottomRightVisible(i_Visible:Boolean):void
		{
			this._hintBottomRightVisible = i_Visible;
			if ( null == this._hSkin )
			{
				return;
			}
			this._hSkin.hintBottomRight.visible = i_Visible;
		}
		
		
		
		[Bindable]
		public function get hintTopLeftColor():uint
		{
			if ( null == this._hSkin )
			{
				return this._hintTopLeftColor;
			}
			return this._hSkin.hintTopLeftColor;
		}
		
		public function set hintTopLeftColor(i_Color:uint):void
		{
			this._hintTopLeftColor = i_Color;
			if ( null == this._hSkin )
			{
				return;
			}
			this._hSkin.hintTopLeftColor = i_Color;
		}
		
		
		
		[Bindable]
		public function get hintTopRightColor():uint
		{
			if ( null == this._hSkin )
			{
				return _hintTopRightColor;
			}
			return this._hSkin.hintTopRightColor;
		}
		
		public function set hintTopRightColor(i_Color:uint):void
		{
			this._hintTopRightColor = i_Color;
			if ( null == this._hSkin )
			{
				return;
			}
			this._hSkin.hintTopRightColor = i_Color;
		}
		
		
		
		[Bindable]
		public function get hintBottomLeftColor():uint
		{
			if ( null == this._hSkin )
			{
				return _hintBottomLeftColor;
			}
			return this._hSkin.hintBottomLeftColor;
		}
		
		public function set hintBottomLeftColor(i_Color:uint):void
		{
			this._hintBottomLeftColor = i_Color;
			if ( null == this._hSkin )
			{
				return;
			}
			this._hSkin.hintBottomLeftColor = i_Color;
		}
		
		
		
		[Bindable]
		public function get hintBottomRightColor():uint
		{
			if ( null == this._hSkin )
			{
				return _hintBottomRightColor;
			}
			return this._hSkin.hintBottomRightColor;
		}
		
		public function set hintBottomRightColor(i_Color:uint):void
		{
			this._hintBottomRightColor = i_Color;
			if ( null == this._hSkin )
			{
				return;
			}
			this._hSkin.hintBottomRightColor = i_Color;
		}
		
		
		
		[Bindable]
		public function get textHide():String
		{
			return _textHide;
		}
		
		public function set textHide(value:String):void
		{
			_textHide = value;
		}
		
		
		
		[Bindable]
		public function get textHideBool():Boolean
		{
			return _textHideBool;
		}
		
		public function set textHideBool(value:Boolean):void
		{
			_textHideBool = value;
		}
		
		
		
		[Bindable]
		public function get textHideNum():Number
		{
			return _textHideNum;
		}
		
		public function set textHideNum(value:Number):void
		{
			_textHideNum = value;
		}
		
		
		
		[Bindable]
		public function get textHideTime():Date
		{
			return _textHideTime;
		}
		
		public function set textHideTime(value:Date):void
		{
			_textHideTime = value;
		}
		
		
		
		[Bindable]
		public function get textHideObj():Object
		{
			return _textHideObj;
		}
		
		public function set textHideObj(value:Object):void
		{
			_textHideObj = value;
		}

	}
}