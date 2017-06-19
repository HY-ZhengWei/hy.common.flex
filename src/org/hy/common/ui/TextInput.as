package org.hy.common.ui
{
	import mx.events.FlexEvent;
	
	import org.hy.common.Help;
	import org.hy.common.skins.spark.TextInputSkin;
	import org.hy.common.ui.event.TextInputEvent;
	
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;
	
	
	
	
	
	/**
	 * 有新、旧值对比不同显示提示信息的文本框。
	 * 
	 * 并且，当有提示信息时，文本框的外观有明显的变化。如在左上角出现一个红的三角形。
	 * 
	 * @author      ZhengWei(HY)
	 * @createDate  2015-12-08
	 * @version     V1.0
	 */
	[Event(name="changedata" ,type="org.hy.common.ui.event.TextInputEvent")]
	public class TextInput extends spark.components.TextInput
	{
		/** 原始值 */
		private var _textOld:String;
		
		/** 原值时间 */
		private var _textOldTime:Date;
		
		/** 新值的编辑时间 */
		private var _textNewTime:Date;
		
		/** 内嵌皮肤 */
		private var _hSkin:TextInputSkin;
		
		
		
		public function TextInput()
		{
			super();
			
			this.addEventListener(FlexEvent.INITIALIZE      ,initializeHandler);
			this.addEventListener(TextOperationEvent.CHANGE ,changeHandler);
			this.setStyle('skinClass' ,TextInputSkin);
		}
		
		
		
		protected function initializeHandler(event:FlexEvent):void
		{
			this._hSkin = this.skin as TextInputSkin;
		}
		
		
		
		protected function changeHandler(i_Event:TextOperationEvent):void
		{
			this.updateHint();
		}
		
		
		
		/**
		 * 更新提示信息
		 */
		protected function updateHint():void
		{
			var v_Info:String = "";
			
			if ( this.text != this._textOld && !Help.isNull(this._textOld) )
			{
				v_Info = "原始值为：" + this._textOld;
				
				if ( this._textOldTime != null )
				{
					v_Info = v_Info + "\n原值时间：" + Help.getDateFull(this._textOldTime);
				}
				
				this._textNewTime = new Date();
				v_Info = v_Info + "\n新值时间：" + Help.getDateFull(this._textNewTime);
			}
			
			this.toolTip = v_Info;
			
			this.hintTopLeftVisible = !Help.isNull(this.toolTip);
			
			// 注意：不允许在此事件中触发提示信息的修改，否则会引发递归事件的错误
			this.dispatchEvent(new TextInputEvent(this ,true ,TextInputEvent.$E_ChangeData));
		}
		
		
		
		[Bindable("change")]
		[Bindable("textChanged")]
		[CollapseWhiteSpace]
		override public function set text(i_Value:String):void
		{
			super.text        = i_Value;
			this._textOld     = i_Value;
			this._textOldTime = new Date();
			this._textNewTime = new Date();
			this.toolTip      = "";
			if ( this._hSkin != null )
			{
				this._hSkin.hintAllVisible = false;
			}
			
			// 注意：不允许在此事件中触发提示信息的修改，否则会引发递归事件的错误
			this.dispatchEvent(new TextInputEvent(this ,false ,TextInputEvent.$E_ChangeData));
		}
		
		
		
		/**
		 * 将提示信息(原始值、原值时间、新值时间)整合为一个对象返回
		 */
		[Bindable]
		public function get textHintInfo():Object
		{
			var v_Ret:Object = new Object();
			
			v_Ret.textOld = Help.NVL(this._textOld ,"");
			
			if ( this._textOldTime != null )
			{
				v_Ret.textOldTime = Help.getDateFull(this._textOldTime);
			}
			else
			{
				v_Ret.textOldTime = "";
			}
			
			if ( this._textNewTime != null )
			{
				v_Ret.textNewTime = Help.getDateFull(this._textNewTime);
			}
			else
			{
				v_Ret.textNewTime = "";
			}
			
			return v_Ret;
		}
		
		
		
		/**
		 * 将提示对象，分解为提示信息(原始值、原值时间、新值时间)
		 */
		public function set textHintInfo(i_HintInfo:Object):void
		{
			if ( i_HintInfo == null )
			{
				this._textOld     = null;
				this._textOldTime = null;
				this._textNewTime = null;
			}
			
			if ( i_HintInfo.hasOwnProperty("textOld") )
			{
				this._textOld = i_HintInfo.textOld as String;
			}
			else
			{
				this._textOld = null;
			}
			
			if ( i_HintInfo.hasOwnProperty("textOldTime") )
			{
				this._textOldTime = Help.toDate(i_HintInfo.textOldTime as String);
			}
			else
			{
				this._textOldTime = null;
			}
			
			if ( i_HintInfo.hasOwnProperty("textNewTime") )
			{
				this._textNewTime = Help.toDate(i_HintInfo.textNewTime as String);
			}
			else
			{
				this._textNewTime = null;
			}
			
			this.updateHint();
		}
		
		
		
		[Bindable]
		public function get textOld():String
		{
			return _textOld;
		}
		
		public function set textOld(value:String):void
		{
			_textOld = value;
			this.updateHint();
		}

		
		
		[Bindable]
		public function get textOldTime():Date
		{
			return _textOldTime;
		}

		public function set textOldTime(value:Date):void
		{
			_textOldTime = value;
			this.updateHint();
		}

		
		
		[Bindable]
		public function get textNewTime():Date
		{
			return _textNewTime;
		}

		public function set textNewTime(value:Date):void
		{
			_textNewTime = value;
			this.updateHint();
		}
		
		
		
		/**
		 * 设置所有提示是否显示或隐藏
		 */
		public function set hintAllVisible(i_Visible:Boolean):void
		{
			this._hSkin.hintAllVisible = i_Visible;
		}
		
		
		
		/**
		 * 设置所有提示的颜色
		 */
		public function set hintAllColor(i_Color:uint):void
		{
			this._hSkin.hintAllColor = i_Color;
		}
		
		
		
		[Bindable]
		public function get hintSize():uint
		{
			return this._hSkin.hintSize;
		}
		
		public function set hintSize(i_HintSize:uint):void
		{
			this._hSkin.hintSize = i_HintSize;
		}
		
		
		
		[Bindable]
		public function get hintTopLeftVisible():Boolean
		{
			return this._hSkin.hintTopLeft.visible;
		}
		
		public function set hintTopLeftVisible(i_Visible:Boolean):void
		{
			this._hSkin.hintTopLeft.visible = i_Visible;
		}
		
		
		
		[Bindable]
		public function get hintTopRightVisible():Boolean
		{
			return this._hSkin.hintTopRight.visible;
		}
		
		public function set hintTopRightVisible(i_Visible:Boolean):void
		{
			this._hSkin.hintTopRight.visible = i_Visible;
		}
		
		
		
		[Bindable]
		public function get hintBottomLeftVisible():Boolean
		{
			return this._hSkin.hintBottomLeft.visible;
		}
		
		public function set hintBottomLeftVisible(i_Visible:Boolean):void
		{
			this._hSkin.hintBottomLeft.visible = i_Visible;
		}
		
		
		
		[Bindable]
		public function get hintBottomRightVisible():Boolean
		{
			return this._hSkin.hintBottomRight.visible;
		}
		
		public function set hintBottomRightVisible(i_Visible:Boolean):void
		{
			this._hSkin.hintBottomRight.visible = i_Visible;
		}
		
		
		
		[Bindable]
		public function get hintTopLeftColor():uint
		{
			return this._hSkin.hintTopLeftColor;
		}
		
		public function set hintTopLeftColor(i_Color:uint):void
		{
			this._hSkin.hintTopLeftColor = i_Color;
		}
		
		
		
		[Bindable]
		public function get hintTopRightColor():uint
		{
			return this._hSkin.hintTopRightColor;
		}
		
		public function set hintTopRightColor(i_Color:uint):void
		{
			this._hSkin.hintTopRightColor = i_Color;
		}
		
		
		
		[Bindable]
		public function get hintBottomLeftColor():uint
		{
			return this._hSkin.hintBottomLeftColor;
		}
		
		public function set hintBottomLeftColor(i_Color:uint):void
		{
			this._hSkin.hintBottomLeftColor = i_Color;
		}
		
		
		
		[Bindable]
		public function get hintBottomRightColor():uint
		{
			return this._hSkin.hintBottomRightColor;
		}
		
		public function set hintBottomRightColor(i_Color:uint):void
		{
			this._hSkin.hintBottomRightColor = i_Color;
		}
		
	}
}