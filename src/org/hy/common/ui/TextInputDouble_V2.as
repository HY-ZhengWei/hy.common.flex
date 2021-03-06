package org.hy.common.ui
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.hy.common.Help;
	import org.hy.common.skins.spark.TextInputDoubleSkin_V2;
	import org.hy.common.ui.event.EventInfo;
	
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
	 *                                升级后，改变思路，使其皮肤用一个RichEditableText组件就轻松实现了同样的功能。维护也简单了。
	 *                                但，与此同时，又产生了新的Bug，无法监听到文本编辑事件，如KeyDown事件。所以，再次弃之。 
	 */
	public class TextInputDouble_V2 extends spark.components.TextInput
	{
		
		/** 最原始外界设置的文本值 */
		private var _textOriginal:String;
		
		/** 真实文本的四舍五入的精度（默认为：9） */
		private var _roundDouble:uint;
		
		/** 用于显示的四舍五入的精度（默认为：3） */
		private var _roundShow:uint;
		
		/** 科学计数法下的四舍五入的精度（默认为：3） */
		private var _roundScientific:uint;
		
		
		
		/** 内嵌皮肤 */
		private var _hSkin:TextInputDoubleSkin_V2;
		
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
		
		
		/** 文本框的延时添加事件监听的事件缓存 */
		private var _textEventInfos:ArrayCollection = new ArrayCollection();
		
		
		
		public function TextInputDouble_V2()
		{
			super();
			
			this._roundDouble     = 9;
			this._roundShow       = 3;
			this._roundScientific = 3;
			
			this._textHide        = null;
			this._textHideBool    = false;
			this._textHideNum     = 0;
			this._textHideTime    = null;
			this._textHideObj     = null;
			
			this.addEventListener(FlexEvent.INITIALIZE ,InitializeHandler);
			this.setStyle('skinClass' ,TextInputDoubleSkin_V2);
			
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
			this._hSkin = this.skin as TextInputDoubleSkin_V2;
			
			this.InitializeAddEvents();
			
			this.addEventListener(FocusEvent.FOCUS_IN       ,FocusInHandler);
			this.addEventListener(FocusEvent.FOCUS_OUT      ,FocusOutHandler);
			this.addEventListener(TextOperationEvent.CHANGE ,ChangeHandler);
			
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
					
					this._hSkin.textDouble.addEventListener(v_EventInfo.type
						                                   ,v_EventInfo.listener
						                                   ,v_EventInfo.useCapture
						                                   ,v_EventInfo.priority
						                                   ,v_EventInfo.useWeakReference);
				}
			}
		}
		
		
		
		/**
		 * 是否为延时要特殊处理的事件
		 * 
		 * ZhengWei(HY) Add 2016-11-23
		 */
		private function isDelayEvent(type:String):Boolean
		{
			if ( type == TextOperationEvent.CHANGE 
			  || type == TextOperationEvent.CHANGING
			  || type == KeyboardEvent.KEY_DOWN 
			  || type == KeyboardEvent.KEY_UP
			  || type == Event.CUT
			  || type == Event.COPY
			  || type == Event.PASTE
			  || type == Event.CLEAR
			  || type == Event.SELECT 
			  || type == Event.SELECT_ALL )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		
		
		/**
		 * 文本框编辑改变事件的特殊处理。
		 * 将 this.addEventListener(CHANGE) 移花接木到 this._hSkin.textDouble.addEventListener(CHANGE) 上。 
		 * 否则外界就无法监听到“改变事件”
		 * 
		 * ZhengWei(HY) Add 2016-11-23
		 */
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if ( this.isDelayEvent(type) )
			{
				if ( this._hSkin != null )
				{
					this._hSkin.textDouble.addEventListener(type, listener, useCapture, priority, useWeakReference);
				}
				else
				{
					this._textEventInfos.addItem(new EventInfo(type ,listener ,useCapture ,priority ,useWeakReference));
				}
			}
			else
			{
				super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		
		
		
		/**
		 * 文本框编辑改变事件的特殊处理。
		 * 将 this.addEventListener(CHANGE) 移花接木到 this._hSkin.textDouble.addEventListener(CHANGE) 上。 
		 * 否则外界就无法监听到“改变事件”
		 * 
		 * ZhengWei(HY) Add 2016-11-23
		 */
		override public function hasEventListener(type:String):Boolean
		{
			var v_Index:int = -1;
			var v_EventInfo:EventInfo = null;
			
			if ( this.isDelayEvent(type) )
			{
				if ( this._hSkin != null )
				{
					return this._hSkin.textDouble.hasEventListener(type);
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
			else
			{
				return super.hasEventListener(type);
			}
		}
		
		
		
		/**
		 * 文本框编辑改变事件的特殊处理。
		 * 将 this.addEventListener(CHANGE) 移花接木到 this._hSkin.textDouble.addEventListener(CHANGE) 上。 
		 * 否则外界就无法监听到“改变事件”
		 * 
		 * ZhengWei(HY) Add 2016-11-23
		 */
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			var v_Index:int = -1;
			var v_EventInfo:EventInfo = null;
			
			if ( this.isDelayEvent(type) )
			{
				if ( this._hSkin != null )
				{
					this._hSkin.textDouble.removeEventListener(type, listener, useCapture);
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
			else
			{
				super.removeEventListener(type, listener, useCapture);
			}
		}
		
		
		
		/**
		 * 文本框编辑改变事件的特殊处理。
		 * 将 this.addEventListener(CHANGE) 移花接木到 this._hSkin.textDouble.addEventListener(CHANGE) 上。 
		 * 否则外界就无法监听到“改变事件”
		 * 
		 * ZhengWei(HY) Add 2016-11-23
		 */
		override public function willTrigger(type:String):Boolean
		{
			var v_Index:int = -1;
			var v_EventInfo:EventInfo = null;
			
			if ( this.isDelayEvent(type) )
			{
				if ( this._hSkin != null )
				{
					return this._hSkin.textDouble.willTrigger(type);
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
			else
			{
				return super.willTrigger(type);
			}
		}
		
		
		
		protected function FocusInHandler(event:FocusEvent):void
		{
			this.hideText();
		}
		
		
		
		protected function FocusOutHandler(event:FocusEvent):void
		{
			this.showText();
		}
		
		
		
		protected function ChangeHandler(event:TextOperationEvent):void
		{
			this._textOriginal = this._hSkin.textDouble.text;
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
			if ( this._hSkin != null && this._hSkin.textDouble.visible )
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
				this._hSkin.textDouble.text = this.text;
			}
			else
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
				
				try
				{
					var v_Num:Number = Help.toNumber(this.text);
					
					if ( isNaN(v_Num) )
					{
						this._hSkin.textDouble.text = this.text;	
					}
					else
					{
						var v_TempText:String = v_Num.toFixed(this._roundShow);
						this._hSkin.textDouble.text = this.text.length <= v_TempText.length ? this.text : v_TempText;
					}
				}
				catch (error:Error)
				{
					this._hSkin.textDouble.text = this.text;
				}
			}
		}
		
		
		
		protected function showText():void
		{
			super.text = this._hSkin.textDouble.text;
			this.setShowText();
		}
		
		
		
		protected function hideText():void
		{
			this._hSkin.textDouble.text = this.text;
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
				return this._hSkin.textDouble.text;
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