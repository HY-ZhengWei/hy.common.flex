package org.hy.common.ui
{
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.hy.common.Help;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.TextInput;
	import spark.components.VGroup;
	
	
	
	
	
	/**
	 * 动态条件面板
	 * 
	 * @author      ZhengWei(HY)
	 * @createDate  2016-09-28
	 * @version     V1.0
	 */
	public class ConditionGroup extends VGroup
	{
		
		/** 最小条件数量 */
		[Bindable]
		public var minCondition:uint = 1;
		
		/** 最大条件数量 */
		[Bindable]
		public var maxCondition:uint = 0;
		
		/** 
		 * 创建条件面板的方法，由使用者来实现。
		 * 方法没有入参
		 * 方法的返回值是：UIComponent对象的实例
		 */
		[Bindable]
		public var newChildFun:Function;
		
		
		
		public function ConditionGroup()
		{
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE ,this.creationCompleteHandler);
		}
		
		
		
		/**
		 * 创建条件面板，此方法可以被继承者"重写"
		 * 
		 * @author      ZhengWei(HY)
		 * @createDate  2016-09-28
		 * @version     V1.0
		 */
		public function newChild():UIComponent
		{
			if ( this.newChildFun != null )
			{
				return this.newChildFun.call();
			}
			else
			{
				return null;
			}
		}
		
		
		
		/**
		 * 创建子面板，并添加一个条件面板UI
		 * 
		 * @author      ZhengWei(HY)
		 * @createDate  2016-09-28
		 * @version     V1.0
		 */
		public function newChildPanel(i_Type:int):UIComponent
		{
			var v_OprButton:Button = new Button();
			v_OprButton.width = 29;
			if ( i_Type >= 1 )
			{
				v_OprButton.label = "+";
				v_OprButton.addEventListener(MouseEvent.CLICK ,addCondition_clickHandler);
			}
			else if ( i_Type <= -1 )
			{
				v_OprButton.label = "-";
				v_OprButton.addEventListener(MouseEvent.CLICK ,delCondition_clickHandler);
			}
			
			
			var v_ChildPanel:HGroup = new HGroup();
			v_ChildPanel.addElement(this.newChild());
			v_ChildPanel.addElement(v_OprButton);
			
			return v_ChildPanel;
		}
		
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			for (var v_Count:uint=1; v_Count<=Math.max(this.minCondition ,1); v_Count++)
			{
				this.addElement(this.newChildPanel(1));
			}
		}
		
		
		
		protected function addCondition_clickHandler(i_Event:MouseEvent):void
		{
			if ( this.maxCondition == 0 || this.conditionCount < this.maxCondition )
			{
				this.addElement(this.newChildPanel(-1));
			}
			else
			{
				Alert.show("最大为" + this.maxCondition + "个" ,"提示");
			}
		}
		
		
		
		protected function delCondition_clickHandler(i_Event:MouseEvent):void
		{
			if ( this.conditionCount > Math.max(this.minCondition ,1) )
			{
				this.removeElement((i_Event.currentTarget as UIComponent).parent as UIComponent);
			}
			else
			{
				Alert.show("最小为" + Math.max(this.minCondition ,1) + "个" ,"提示");
			}
		}
		
		
		
		/**
		 * 获取所有条件面板
		 * 
		 * @author      ZhengWei(HY)
		 * @createDate  2016-09-28
		 * @version     V1.0
		 */
		public function get conditions():ArrayList
		{
			var v_Ret:ArrayList = new ArrayList();
			
			for (var v_Index:uint=0; v_Index<this.numElements; v_Index++)
			{
				v_Ret.addItem((this.getElementAt(v_Index) as HGroup).getElementAt(0));
			}
			
			return v_Ret;
		}
		
		
		
		/**
		 * 当前条件数量
		 * 
		 * @author      ZhengWei(HY)
		 * @createDate  2016-09-28
		 * @version     V1.0
		 */
		public function get conditionCount():uint
		{
			return this.numElements;
		}
		
		
		
		/**
		 * 生成查询条件(Where)的SQL
		 * 
		 * @author      ZhengWei(HY)
		 * @createDate  2016-09-28
		 * @version     V1.0
		 */
		public function getSQL():String
		{
			var v_Conditions:ArrayList = this.conditions;
			var v_SQL:String           = "";
			
			if ( this.conditions.length >= 1 )
			{
				for (var v_Index:uint=0; v_Index<v_Conditions.length; v_Index++)
				{
					v_SQL += (v_Conditions.getItemAt(v_Index) as Condition).getSQL();
				}
			}
			
			return v_SQL;
		}
		
		
		
		/**
		 * 生成Update属性设置(Set)的SQL
		 * 
		 * @author      ZhengWei(HY)
		 * @createDate  2016-09-28
		 * @version     V1.0
		 */
		public function getSQLUpdate():String
		{
			var v_Conditions:ArrayList = this.conditions;
			var v_SQL:String           = "";
			
			if ( this.conditions.length >= 1 )
			{
				for (var v_Index:uint=0; v_Index<v_Conditions.length; v_Index++)
				{
					v_SQL += (v_Conditions.getItemAt(v_Index) as Condition).getSQLUpdate();
					
					if ( v_Index < v_Conditions.length -1 )
					{
						v_SQL += ",";
					}
				}
			}
			
			return v_SQL;
		}
		
	}
}