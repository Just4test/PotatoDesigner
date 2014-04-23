package potato.ui{
	import core.display.Image;
	import core.display.SuperTexture;
	import core.display.Texture;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class RadianProcess extends Image
	{
		private static const PI2:Number = Math.PI * 2;
		
		private var parentTex:Texture;		//父材质
		private var minRadian:Number=0;		//最小弧度
		private var maxRadian:Number=PI2;	//最大弧度
		private var centerPt:Point;			//圆的中心点
		
		private var triangles:Vector.<Number>;
		private var indexs:Vector.<int>;
		
		private var clockWise:Boolean = true;	//顺时针
		private var total:Number = 0;
		private var firstVertex:int;
		
		private var vertexs:Vector.<Vertex>;	//顶点数组，临时用
		private var vertexDic:Dictionary;		//弧度对应的顶点
		
		// 材质矩形的顶点弧度
		private var r:Vector.<Number> = new Vector.<Number>(4);
		
		/**
		 * 
		 * @param tex	 使用的材质，不可为 SuperTexture和SubTexture
		 * @param centerPt	旋转的中心点
		 * @param clockWise	是否为顺时针旋转
		 * @param minAngle	旋转的最小角度
		 * @param maxAngle	旋转的最大角度
		 * @param defaultAngle	初始的默认位置，值范围 0--1
		 */		
		public function RadianProcess(tex:Texture, centerPt:Point=null, clockWise:Boolean=true,
									  minAngle:Number=0, maxAngle:Number=360, defaultPos:Number=0)
		{
			exactHitTest = true;
			super(null);
			
			this.parentTex = tex;
			this.minRadian = minAngle * Math.PI/180;
			this.maxRadian = maxAngle * Math.PI/180;
			this.centerPt = centerPt;
			this.clockWise = clockWise;
			
//			if (minAngle == maxAngle) throw ArgumentError("Illegal angle range.");
			if (centerPt != null) {
				if (centerPt.x < 0 || centerPt.x > tex.width) throw ArgumentError("CenterPt must be in texture rect.");
				if (centerPt.y < 0 || centerPt.y > tex.height) throw ArgumentError("CenterPt must be in texture rect.");
			}
			
			totalRadian();
			
			init();
			setPostion(defaultPos);
		}
		
		private function init():void {
			//////////根据 minAngle 和 maxAngle 及 材质矩形 计算初始三角形 /////////
			// 未指定中心点时，以材质的中点作为中心点
			if (centerPt == null) {
				centerPt = new Point(parentTex.width/2, parentTex.height/2);
			}
			
			vertexDic = new Dictionary();
			
			// 材质矩形 4 个角的弧度
			//右下	0 -- 90
			r[0] = Math.atan2(parentTex.height-centerPt.y, parentTex.width-centerPt.x);
			vertexDic[r[0]] = new Vertex(parentTex.width, parentTex.height, parentTex.width, parentTex.height);
			//左下 	90 -- 180
			r[1] = Math.atan2(parentTex.height-centerPt.y, -centerPt.x);
			vertexDic[r[1]] = new Vertex(0, parentTex.height, 0, parentTex.height);
			//左上	180 -- 270
			r[2] = Math.atan2(-centerPt.y, -centerPt.x) + PI2;
			vertexDic[r[2]] = new Vertex(0, 0, 0, 0);
			//右上 	270 -- 360
			r[3] = Math.atan2(-centerPt.y, parentTex.width-centerPt.x) + PI2;
			vertexDic[r[3]] = new Vertex(parentTex.width, 0, parentTex.width, 0);
			
			// 计算交点
			var minPt:Point = intersection(minRadian);		//最小弧度交点
			var maxPt:Point = intersection(maxRadian);		//最大弧度交点
			vertexDic[minRadian] = new Vertex(minPt.x, minPt.y, minPt.x, minPt.y);
			vertexDic[maxRadian] = new Vertex(maxPt.x, maxPt.y, maxPt.x, maxPt.y);
			
			////查找起始顶点
			findFirstVertex();
		}
		
		/**
		 * 计算 弧度 与矩形边的交点
		 */		
		private function intersection(radian:Number):Point {
			var ix:Number;
			var iy:Number;
			if (radian <= r[0]) {
				ix = parentTex.width;
				iy = (ix-centerPt.x) * Math.tan(radian) + centerPt.y;
			} else if (radian > r[0] && radian <= r[1]) {
				iy = parentTex.height;
				ix = (iy-centerPt.y) / Math.tan(radian) + centerPt.x;
			} else if (radian > r[1] && radian <= Math.PI) {
				ix = 0;
				iy = (-centerPt.x) * Math.tan(radian) + centerPt.y;
			} else if (radian > Math.PI && radian <= r[2]) {
				ix = 0;
				iy = (-centerPt.x) * Math.tan(radian-PI2) + centerPt.y;
			} else if (radian > r[2] && radian <= r[3]) {
				ix = centerPt.y / Math.tan(PI2-radian) + centerPt.x;
				iy = 0;
			} else {  //minRadian > r[3] && minRadian <= PI2
				ix = parentTex.width;
				iy = (ix-centerPt.x) * Math.tan(radian-PI2) + centerPt.y;
			}
			return new Point(ix, iy);
		}
		
		private function totalRadian():void {
			if (clockWise) {
				if (minRadian >= maxRadian) {
					total = PI2 - minRadian + maxRadian;
				} else {
					total = maxRadian - minRadian;
				}
			} else {
				if (minRadian <= maxRadian) {
					total = PI2 - maxRadian + minRadian;
				} else {
					total = minRadian - maxRadian;
				}
			}
		}
		
		private function findFirstVertex():void {
			//查找起始顶点
			var i:int;
			if (clockWise) {
				if (minRadian > r[3]) {
					firstVertex = 0;
				} else {
					for (i=0; i<4; i++) {
						if (minRadian < r[i]) {
							firstVertex = i;
							return;
						}
					}
				}
			} else {
				if (minRadian < r[0]) {
					firstVertex = 3;
				} else {
					for (i=3; i>=0; i--) {
						if (minRadian > r[i]) {
							firstVertex = i;
							return;
						}
					}
				}
			}
		}
		
		/**
		 * 设置当前位置，参数值范围 0--1 
		 * @param position
		 */	
		public function setPostion(position:Number):void {
			var vt:Vector.<Number> = new Vector.<Number>();	//需要显示的顶点序列
			vt.push(minRadian);
			
			var rp:Number;	//位置对应的弧度
			var rpt:Point;	//位置对应的坐标
			var k:int = 5;
			
			var isCross:Boolean = false;
			var i:int = firstVertex;
			if (clockWise) { // 顺时针 
				rp = position * total + minRadian;
					
				if (rp > PI2) {
					isCross = true;
					rp = rp - PI2;
				}
				rpt = intersection(rp);
				vertexDic[rp] = new Vertex(rpt.x, rpt.y, rpt.x, rpt.y);
				
				while (k-- > 0) {
					if (isCross) {
						if (r[i] > minRadian ) {
							vt.push(r[i]);
						}
					} else if (minRadian > r[3] && rp <= PI2) {
						break;
					} else if (r[i] < rp) {
						vt.push(r[i]);
					} else {
						break;
					}
					i++;
					if (i > 3) {
						if (isCross) {
							i = 0;
							isCross = false;
						} else {
							break;
						}
					}
				}
				
				vt.push(rp);
			} else { //逆时针
				rp = minRadian - position * total;
				
				if (rp < 0) {
					isCross = true;
					rp = rp + PI2;
				}
				rpt = intersection(rp);
				vertexDic[rp] = new Vertex(rpt.x, rpt.y, rpt.x, rpt.y);
				
				while (k-- > 0) {
					if (isCross) {
						if (i == 3 && r[i] > rp) {
							vt.push(r[i]);
						} else if (r[i] < minRadian) {
							vt.push(r[i]);
						}
					} else if (minRadian < r[0] && rp >= 0) {
						break;
					} else if (r[i] > rp) {
						vt.push(r[i]);
					} else {
						break;
					}
					i--;
					if (i < 0) {
						if (isCross) {
							i = 3;
							isCross = false;
						} else {
							break;
						}
					}
				}
				
				vt.push(rp);
			}
			
//			trace("processVertexs,", vt.length, position);
			
			processVertexs(vt);
			
			var st:SuperTexture = new SuperTexture(parentTex);
			st.addTriangles(triangles, indexs);
			this.texture = st;
		}
		
		private function addVertex(v:Vertex):void {
			for (var i:int=0; i<vertexs.length; i++) {
				if (v.equal(vertexs[i])) {
					indexs.push(i);
					return;
				}
			}
			indexs.push(vertexs.length);
			vertexs.push(v);
		}
		
		private function processVertexs(vt:Vector.<Number>):void {
			vertexs = new Vector.<Vertex>();
			indexs = new Vector.<int>();
			triangles = new Vector.<Number>();
			
			var vc:Vertex = new Vertex(centerPt.x, centerPt.y, centerPt.x, centerPt.y);
			
			for (var i:int=1; i<vt.length; i++) {
				addVertex(vc);
				addVertex(vertexDic[vt[i]]);
				addVertex(vertexDic[vt[i-1]]);
			}
			
			for each (var v:Vertex in vertexs) {
//				trace(v);
				triangles.push(v.v1, v.v2, v.v3, v.v4);
			}
//			trace("=========");
//			for each (var n:Number in indexs) {
//				trace(n);
//			}
		}
	}
}

class Vertex {
	public var v1:Number;
	public var v2:Number;
	public var v3:Number;
	public var v4:Number;
	
	public function Vertex(v1:Number, v2:Number, v3:Number, v4:Number) {
		this.v1 = v1;
		this.v2 = v2;
		this.v3 = v3;
		this.v4 = v4;
	}
	
	public function equal(v:Vertex):Boolean {
		if (v1 == v.v1 && v2 == v.v2 && v3 == v.v3 && v4 == v.v4) {
			return true;
		} else {
			return false;
		}
	}
	
	public function toString():String {
		return "Vertex (" + v1 + "," + v2 + "," + v3 + "," + v4 + ")";
	}
}
