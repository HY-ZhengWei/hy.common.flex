package org.hy.common.skins.mx
{
	import flash.events.MouseEvent;
	
	import mx.containers.Box;
	import mx.controls.Image;
	import mx.events.DividerEvent;
	
	import org.hy.common.Help;
	import org.hy.common.ui.DividedBox;
	import org.hy.common.ui.GroupBColor;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.VGroup;
	
	
	
	/**
	 * 带图标并实现可关闭隐藏功能的分割条样式
	 * 
	 * 使用方法：<mx:DividedBox dividerSkin="org.hy.common.skins.DividerBoxSkin" height="100%" />
	 * 
	 * @author      ZhengWei(HY)
	 * @createDate  2015-07-11
	 * @version     V1.0
	 */
	public class DividedBoxSkin extends Box
	{
		
		/** 摆放位置层 */
		private var _groupPlace:GroupBColor;
		
		/** 控制层 */
		private var _groupControl:Group;
		
		/** 水平分割时，左侧宽度 */
		private var _leftWidth:int;
		
		/** 水平分割时，右侧宽度 */
		private var _rightWidth:int;
		
		/** 垂直分割时，顶部高度 */
		private var _topHeight:int;
		
		/** 垂直分割时，底部高度 */
		private var _bottonHeight:int;
		
		/** 分割条对象本身 */
		private var _dividedBox:DividedBox;
		
		
		
		public function DividedBoxSkin()     
		{     
			super();
			
			this.clipContent = true;
		}     
		
		
		
		override protected function createChildren():void
		{     
			super.createChildren();     
			
			if ( !(this.parent.parent.parent as DividedBox) )
			{
				return;
			}
			
			this._dividedBox = this.parent.parent.parent as DividedBox;
			
			if ( this._dividedBox.imgLeft == null || this._dividedBox.imgRight == null )
			{
				return;
			}
			
			this._groupPlace = new GroupBColor();
			// this._groupPlace.borderColor = Help.toColor("#FF0000");
			
			if ( this._dividedBox.isHorizontal )
			{
				// 默认为水平分割的分割条
				this._groupControl = new VGroup();
				this._groupControl.addElement(this._dividedBox.imgLeft);
				this._groupControl.addElement(this._dividedBox.imgRight);
				this._groupPlace.addElement(_groupControl);
				
				this._groupControl.top = "2";
				
				this.width  = this._dividedBox.imgLeft.height * 2 + 10;
				this.height = this._dividedBox.imgLeft.width * 2 + 10;  // 已被反转，所以height就是宽度
			}
			else
			{
				this._groupControl = new VGroup();
				this._groupControl.addElement(this._dividedBox.imgLeft);
				this._groupControl.addElement(this._dividedBox.imgRight);
				this._groupPlace.addElement(_groupControl);
				
				this._groupControl.top = "2";
				
				this.width  = this._dividedBox.imgLeft.width;
				this.height = this._dividedBox.imgLeft.height * 2 + 10;
			}
			
			// 默认对DividedBox进行了旋转，所以需要旋转回来    
			this._dividedBox.imgLeft .rotation = 90;
			this._dividedBox.imgRight.rotation = 90;
			
			this.addChild(this._groupPlace);
			this._dividedBox.imgLeft .addEventListener(MouseEvent.CLICK ,onMouseClickOfLeftOrTop);
			this._dividedBox.imgRight.addEventListener(MouseEvent.CLICK ,onMouseClickOfRightOrBotton);
			//this._dividedBox.addEventListener(DividerEvent.DIVIDER_DRAG ,onMouseDividerReleaseHandler);
		}
		
		
		
		/**
		 * 计算分割条的位置（相对于被分割的内容）
		 * 
		 * -1：表示分割条在最左边（或最顶部），只有右边（或底部）内容显示出
		 *  0：表示分割条在中间，两则均有内容显示出
		 *  1：表示分割条在最右边（或最底部），只有左边（或顶部）内容显示出
		 */
		private function computePlace():int
		{
			if ( this._dividedBox.isHorizontal )
			{
				if ( this._dividedBox.getChildAt(0).width > 0 && this._dividedBox.getChildAt(1).width > 0 )
				{
					return 0;
				}
				else if ( this._dividedBox.getChildAt(0).width <= 0 && this._dividedBox.getChildAt(1).width > 0 )
				{
					return -1;	
				}
				else if ( this._dividedBox.getChildAt(0).width > 0 && this._dividedBox.getChildAt(1).width <= 0 )
				{
					return 1;
				}
				else
				{
					return 0;
				}
			}
			else
			{
				if ( this._dividedBox.getChildAt(0).height > 0 && this._dividedBox.getChildAt(1).height > 0 )
				{
					return 0;
				}
				else if ( this._dividedBox.getChildAt(0).height <= 0 && this._dividedBox.getChildAt(1).height > 0 )
				{
					return -1;	
				}
				else if ( this._dividedBox.getChildAt(0).height > 0 && this._dividedBox.getChildAt(1).height <= 0 )
				{
					return 1;
				}
				else
				{
					return 0;
				}
			}
		}
		
		
		
		/**
		 * 分割条变化时触发的事件（鼠标拖拽引起的改变） 
		 */
		private function onMouseDividerReleaseHandler(event:DividerEvent):void
		{
			var v_Place:int = this.computePlace();
			
			if ( v_Place == 0 )
			{
				this.setImageEnable(this._dividedBox.imgLeft  ,true);
				this.setImageEnable(this._dividedBox.imgRight ,true);
			}
			else if ( v_Place == 1 )
			{
				this.setImageEnable(this._dividedBox.imgLeft  ,true);
				this.setImageEnable(this._dividedBox.imgRight ,false);
			}
			else
			{
				this.setImageEnable(this._dividedBox.imgLeft  ,false);
				this.setImageEnable(this._dividedBox.imgRight ,true);
			}
		}
		
		
		
		/**
		 * 向左或向上
		 * 
		 * 情况1. 当分割条的位置在中间时，执行后左则（或项部）内部被隐藏
		 * 情况2. 当分割条的位置在最右时，执行后分割条在中间，两则内部均可见
		 */
		private function onMouseClickOfLeftOrTop(event:MouseEvent):void
		{
			var v_Place:int = this.computePlace();
			
			if ( this._dividedBox.isHorizontal )
			{
				if ( v_Place == 0 )
				{     
					this._leftWidth                      = this._dividedBox.getChildAt(0).width;
					this._rightWidth                     = this._dividedBox.getChildAt(1).width;
					this._dividedBox.getChildAt(0).width = 0;
					this._dividedBox.getChildAt(1).width = this._leftWidth + this._rightWidth;
					this.setImageEnable(this._dividedBox.imgLeft  ,false);
					this.setImageEnable(this._dividedBox.imgRight ,true);
				}
				else if ( v_Place == 1 )
				{
					if ( this._leftWidth == 0 && this._rightWidth == 0 )
					{
						this._dividedBox.getChildAt(0).width = this._dividedBox.width / 2;
						this._dividedBox.getChildAt(1).width = this._dividedBox.width / 2;
					}
					else 
					{
						this._dividedBox.getChildAt(0).width = this._leftWidth;
						this._dividedBox.getChildAt(1).width = this._rightWidth;
					}
					
					this.setImageEnable(this._dividedBox.imgLeft  ,true);
					this.setImageEnable(this._dividedBox.imgRight ,true);
				}
				else
				{
					// 已在最左则，无法再向左了
				}
			}
			else
			{
				if ( v_Place == 0 )
				{     
					this._topHeight                       = this._dividedBox.getChildAt(0).height;
					this._bottonHeight                    = this._dividedBox.getChildAt(1).height;
					this._dividedBox.getChildAt(0).height = 0;
					this._dividedBox.getChildAt(1).height = this._topHeight + this._bottonHeight;
					this.setImageEnable(this._dividedBox.imgLeft  ,false);
					this.setImageEnable(this._dividedBox.imgRight ,true);
				}
				else if ( v_Place == 1 )
				{
					if ( this._topHeight == 0 && this._bottonHeight == 0 )
					{
						this._dividedBox.getChildAt(0).height = this._dividedBox.height / 2;
						this._dividedBox.getChildAt(1).height = this._dividedBox.height / 2;
					}
					else
					{
						this._dividedBox.getChildAt(0).height = this._topHeight;
						this._dividedBox.getChildAt(1).height = this._bottonHeight;
					}
					
					this.setImageEnable(this._dividedBox.imgLeft  ,true);
					this.setImageEnable(this._dividedBox.imgRight ,true);
				}
				else
				{
					// 已在最顶部，无法再向上了
				}
			}
		}
		
		
		
		/**
		 * 向右或向下
		 * 
		 * 情况1. 当分割条的位置在中间时，执行后左则（或项部）内部被隐藏
		 * 情况2. 当分割条的位置在最右时，执行后分割条在中间，两则内部均可见
		 */
		private function onMouseClickOfRightOrBotton(event:MouseEvent):void
		{
			var v_Place:int = this.computePlace();
			
			if ( this._dividedBox.isHorizontal )
			{
				if ( v_Place == 0 )
				{     
					this._leftWidth                      = this._dividedBox.getChildAt(0).width;
					this._rightWidth                     = this._dividedBox.getChildAt(1).width;
					this._dividedBox.getChildAt(0).width = this._leftWidth + this._rightWidth;
					this._dividedBox.getChildAt(1).width = 0;
					this.setImageEnable(this._dividedBox.imgLeft  ,true);
					this.setImageEnable(this._dividedBox.imgRight ,false);
				}
				else if ( v_Place == -1 )
				{
					if ( this._leftWidth == 0 && this._rightWidth == 0 )
					{
						this._dividedBox.getChildAt(0).width = this._dividedBox.width / 2;
						this._dividedBox.getChildAt(1).width = this._dividedBox.width / 2;
					}
					else
					{
						this._dividedBox.getChildAt(0).width = this._leftWidth;
						this._dividedBox.getChildAt(1).width = this._rightWidth;
					}
					
					this.setImageEnable(this._dividedBox.imgLeft  ,true);
					this.setImageEnable(this._dividedBox.imgRight ,true);
				}
				else
				{
					// 已在最右则，无法再向右了
				}
			}
			else
			{
				if ( v_Place == 0 )
				{     
					this._topHeight                       = this._dividedBox.getChildAt(0).height;
					this._bottonHeight                    = this._dividedBox.getChildAt(1).height;
					this._dividedBox.getChildAt(0).height = this._topHeight + this._bottonHeight;
					this._dividedBox.getChildAt(1).height = 0;
					this.setImageEnable(this._dividedBox.imgLeft  ,true);
					this.setImageEnable(this._dividedBox.imgRight ,false);
				}
				else if ( v_Place == -1 )
				{
					if ( this._topHeight == 0 && this._bottonHeight == 0 )
					{
						this._dividedBox.getChildAt(0).height = this._dividedBox.height / 2;
						this._dividedBox.getChildAt(1).height = this._dividedBox.height / 2;
					}
					else
					{
						this._dividedBox.getChildAt(0).height = this._topHeight;
						this._dividedBox.getChildAt(1).height = this._bottonHeight;
					}
					
					this.setImageEnable(this._dividedBox.imgLeft  ,true);
					this.setImageEnable(this._dividedBox.imgRight ,true);
				}
				else
				{
					// 已在最底部，无法再向下了
				}
			}
		}
		
		
		
		/**
		 * 设置图片的可用性，当图片为不可用时，图片透明度下降
		 */
		private function setImageEnable(i_Image:Image ,i_Enable:Boolean):void
		{
			i_Image.enabled = i_Enable;
			
			if ( i_Enable )
			{
				i_Image.alpha = 1;
			}
			else
			{
				i_Image.alpha = 0.2;
			}
		}
		
	}
}