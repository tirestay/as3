package azura.banshee.zforest
{
	import azura.avalon.zbase.zway.Zway;
	import azura.banshee.zebra.Zebra;
	import azura.banshee.zforest.zmask.Zmask;
	import azura.common.algorithm.FastMath;
	import azura.common.collections.ZintBuffer;
	import azura.gallerid3.i.GsI;
	import azura.avalon.zbase.Zbase;
	import azura.avalon.zbase.zway.Zway;
	
	public class Zforest implements GsI
	{
		/**
		 *in percentage 
		 */
		public var scale:int=100;
		public var land:Zebra=new Zebra();
		public var mask:Zmask=new Zmask();
		public var base:Zbase=new Zbase();
		public var way:Zway;
		public var ztreeList:Vector.<Ztree>=new Vector.<Ztree>();
		
		public var zbaseScale:int;
		
		public function loadZway(data:ZintBuffer):void{
			way=new Zway();
			way.fromBytes(data);
			zbaseScale=FastMath.pow2x(base.zMax-way.base.zMax);
		}
		
		public function fromBytes(zb:ZintBuffer):void
		{
			ztreeList=new Vector.<Ztree>();
			
			scale=zb.readZint();
			land.fromBytes(zb.readBytesZ());
			mask.fromBytes(zb.readBytesZ());
			base.fromBytes(zb.readBytesZ());
			loadZway(zb.readBytesZ());
			var length:int=zb.readZint();
			for(var i:int=0;i<length;i++){
				var zt:Ztree=new Ztree();
				zt.fromBytes(zb.readBytesZ());
				ztreeList.push(zt);
			}
		}
		
		public function toBytes():ZintBuffer
		{
			if(way==null)
				way=new Zway();
			
			var zb:ZintBuffer=new ZintBuffer();
			zb.writeZint(scale);
			zb.writeBytesZ(land.toBytes());
			zb.writeBytesZ(mask.toBytes());
			zb.writeBytesZ(base.toBytes());
			zb.writeBytesZ(way.toBytes());
			zb.writeZint(ztreeList.length);
			for each(var zt:Ztree in ztreeList){
				zb.writeBytesZ(zt.toBytes());
			}
			return zb;
		}
		
		public function getMe5List():Vector.<String>{
			var list:Vector.<String>=new Vector.<String>();
			var mc5:String;
			for each(mc5 in land.getMe5List()){
				list.push(mc5);	
			}
			for each(mc5 in mask.getMe5List()){
				list.push(mc5);	
			}
			for each(var zt:Ztree in ztreeList){
				for each(mc5 in zt.zebra.getMe5List()){
					list.push(mc5);	
				}
			}
			return list;
		}
	}
}
