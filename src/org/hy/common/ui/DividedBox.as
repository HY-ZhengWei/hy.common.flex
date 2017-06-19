package org.hy.common.ui
{
	import flash.events.MouseEvent;
	
	import mx.containers.Box;
	import mx.containers.BoxDirection;
	import mx.containers.DividedBox;
	import mx.controls.Image;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.VGroup;

	
	
	
	
	/**
	 * 带图标并实现可关闭隐藏功能的分割条
	 * 
	 * @author      ZhengWei(HY)
	 * @createDate  2015-07-11
	 * @version     V1.0
	 */
	public class DividedBox extends mx.containers.DividedBox
	{
		
		/** 左方向图片 */
		private var _imgLeft:Image;
		
		/** 右方向图片 */
		private var _imgRight:Image;
		
						
		
		public function DividedBox()
		{
			super();

			this._imgLeft  = new Image();
			this._imgRight = new Image();
			
			this._imgLeft.source  = "@Embed('images/left.png')";
			this._imgRight.source = "@Embed('images/right.png')";
		}
		
		
		
		[Bindable]
		public function get isHorizontal():Boolean
		{
			return this.direction == BoxDirection.HORIZONTAL;
		}
		
		public function set isHorizontal(i_IsHorizontal:Boolean):void
		{
			this.direction = BoxDirection.HORIZONTAL;
		}
		
		
		
		
		[Bindable]
		public function get isVertical():Boolean
		{
			return this.direction == BoxDirection.VERTICAL;
		}
		
		public function set isVertical(i_IsVertical:Boolean):void
		{
			this.direction = BoxDirection.VERTICAL;
		}
		
		
		
		[Bindable]
		public function get imgLeft():Image
		{
			return this._imgLeft;	
		}
		
		public function set imgLeft(imgLeft:Image):void
		{
			this._imgLeft = imgLeft;
		}
		
		public function setImgLeft(i_ImgNameLeft:String ,i_Width:int ,i_Height:int):void
		{
			this._imgLeft          = new Image();
			this._imgLeft.autoLoad = true;
			this._imgLeft.source   = i_ImgNameLeft;
			this._imgLeft.width    = i_Width;
			this._imgLeft.height   = i_Height;
		}
		
		
		
		[Bindable]
		public function get imgRight():Image
		{
			return this._imgRight;	
		}
		
		public function set imgRight(imgRight:Image):void
		{
			this._imgRight = imgRight;
		}
		
		public function setImgRight(i_ImgNameRight:String ,i_Width:int ,i_Height:int):void
		{
			this._imgRight          = new Image();
			this._imgRight.autoLoad = true;
			this._imgRight.source   = i_ImgNameRight;
			this._imgRight.width    = i_Width;
			this._imgRight.height   = i_Height;
		}
		
	}
}