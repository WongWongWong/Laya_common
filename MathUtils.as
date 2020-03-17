/**
 * @author: Danny
 * @time: 2020-2-25 下午2:43:01
 * @description: MathUtils 通用数学
 */
package com.eyu.framework.utils
{
	import laya.d3.math.Vector2;
	import laya.maths.Point;

	public class MathUtils
	{
		/**
		 * 随机整数 
		 * @param min
		 * @param max
		 * @return 
		 * 
		 */		
		public static function randomInt(min:int,max:int):int
		{
			return Math.round(MathUtils.random(min,max));
		}
		
		/**
		 * 随机小数 
		 * @param min
		 * @param max
		 * @return 
		 * 
		 */		
		public static function random(min:Number,max:Number):Number
		{
			return min + Math.random() * (max - min);
		}
		
		/**
		 * 求弧度 
		 * @param startPt
		 * @param endPt
		 * @return 
		 * 
		 */		
		public static function getRad(startPt:Point,endPt:Point):Number
		{
			var valX:Number = endPt.x - startPt.x;
			var valY:Number = endPt.y - startPt.y;
			
			var rad:Number = Math.atan2(valY,valX);
			return rad;
		}
		
		/**
		 * 求角度 
		 * @param startPt
		 * @param endPt
		 * @return 
		 * 
		 */		
		public static function getAngle(startPt:Point,endPt:Point):Number
		{
			var rad:Number = MathUtils.getRad(startPt,endPt);
			var angle:Number = rad / Math.PI * 180;
			
			return angle;
		}
		
		/**
		 * 获得向量 
		 * @param startPt
		 * @param endPt
		 * @return 
		 * 
		 */		
		public static function getVector(startPt:Point,endPt:Point):Vector2
		{
			var rad:Number = MathUtils.getRad(startPt,endPt);
			
			var x:Number = Math.cos(rad);
			var y:Number = Math.sin(rad);
			
			return new Vector2(x,y);
		}
		
		/**
		 * 计算两点之间的距离 
		 * @param x1
		 * @param y1
		 * @param x2
		 * @param y2
		 * 
		 */		
		public static function DistanceBetweenTwoPoints(x1:Number,y1:Number,x2:Number,y2:Number):Number
		{
			return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
		}
		
		/**
		 * 计算点(x, y)到经过两点(x1, y1)和(x2, y2)的直线的距离 
		 * @param x
		 * @param y
		 * @param x1
		 * @param y1
		 * @param x2
		 * @param y2
		 * @return 
		 * 
		 */		
		public static function DistanceFromPointToLine(x:Number, y:Number, x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var a:Number = y2 - y1;
			var b:Number = x1 - x2;
			var c:Number = x2 * y1 - x1 * y2;
			
//			assert(fabs(a) > 0.00001f || fabs(b) > 0.00001f);
			
			return Math.abs(a * x + b * y + c) / Math.sqrt(a * a + b * b);
		}
		
		/**
		 * 圆与矩形碰撞检测
		 * 圆心(x, y), 半径r, 矩形中心(x0, y0), 矩形上边中心(x1, y1), 矩形右边中心(x2, y2) 
		 * @param x
		 * @param y
		 * @param r
		 * @param x0
		 * @param y0
		 * @param x1
		 * @param y1
		 * @param x2
		 * @param y2
		 * @return 
		 * 
		 */		
		public static function IsCircleIntersectRectangle(x:Number,y:Number,r:Number,x0:Number,y0:Number,x1:Number,y1:Number,x2:Number,y2:Number):Boolean
		{
			var w1:Number = DistanceBetweenTwoPoints(x0, y0, x2, y2);
			var h1:Number = DistanceBetweenTwoPoints(x0, y0, x1, y1);
			var w2:Number = DistanceFromPointToLine(x, y, x0, y0, x1, y1);
			var h2:Number = DistanceFromPointToLine(x, y, x0, y0, x2, y2);
			
			if (w2 > w1 + r)
				return false;
			if (h2 > h1 + r)
				return false;
			
			if (w2 <= w1)
				return true;
			if (h2 <= h1)
				return true;
			
			return (w2 - w1) * (w2 - w1) + (h2 - h1) * (h2 - h1) <= r * r;
		}
	}
}