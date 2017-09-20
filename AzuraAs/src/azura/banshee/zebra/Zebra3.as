package azura.banshee.zebra
{
	import azura.banshee.zebra.branch.ZHline2;
	import azura.banshee.zebra.branch.ZVline2;
	import azura.banshee.zebra.branch.Zblank2;
	import azura.banshee.zebra.branch.Zebra2BranchI;
	import azura.banshee.zebra.branch.ZimageLarge2;
	import azura.banshee.zebra.branch.ZimageSmall2;
	import azura.banshee.zebra.branch.Zmatrix2;
	import azura.banshee.zebra.data.wrap.Zatlas2;
	import azura.common.collections.BytesI;
	import azura.common.collections.RectC;
	import azura.common.collections.ZintBuffer;
	import azura.gallerid4.Gal4PackI;
	
	import flash.display.BitmapData;
	
	public class Zebra3 implements Gal4PackI,BytesI
	{
		private static  var formatVersion:int = 2016020910;
		
		public static  var BLANK:int = 0;
		public static var IMAGE_BITMAP:int=1;
		public static  var IMAGE_SMALL:int= 2;
		public static  var IMAGE_LARGE:int= 3;
		public static  var HLINE:int= 4;
		public static  var VLINE:int= 5;
		public static  var MATRIX:int= 6;
//		public static var FONT:int=7;
		
		public var atlas:Zatlas2=new Zatlas2();
		public var boundingBox:RectC=new RectC();
		public var branch:Zebra2BranchI=new Zblank2();
		
		//		public function fromBitmapData(bd:BitmapData):Zebra3{
		//			branch=new Zbitmap3();
		//			boundingBox.width=bd.width;
		//			boundingBox.height=bd.height;
		//			Zbitmap3(branch).bitmapData=bd;
		//			return this;
		//		}
		
		public function fromBytes(zb:ZintBuffer):void
		{
			var fileFormatVersion:int= zb.readInt();
			if (fileFormatVersion != formatVersion)
				throw new Error();
			
			clear();
			
			boundingBox.readFrom(zb);
			atlas.fromBytes(zb.readBytesZ());
			
			var type:int=zb.readZint();			
			if(type==BLANK){
				branch=new Zblank2();
			}else if(type==IMAGE_BITMAP){
				//				branch=new Zbitmap3();
			}else if(type==IMAGE_SMALL){
				branch=new ZimageSmall2();
			}else if(type==IMAGE_LARGE){
				branch=new ZimageLarge2();
			}else if(type==HLINE){
				branch=new ZHline2();
			}else if(type==VLINE){
				branch=new ZVline2();
			}else if(type==MATRIX){
				branch=new Zmatrix2();
//			}else if(type==FONT){
//				branch=new Zfont();
			}else{
				throw new Error("Zebra: unknown format");
			}
			branch.readFrom(zb);
			branch.atlas=atlas;
		}
		
		public function toBytes():ZintBuffer
		{
			var zb:ZintBuffer=new ZintBuffer();
			zb.writeInt(formatVersion);
			boundingBox.writeTo(zb);
			zb.writeBytesZ(atlas.toBytes());
			zb.writeZint(type);
			branch.writeTo(zb);
			return zb;
		}
		
		public function get type():int{
			if(branch is Zblank2)
				return BLANK;
				//			else if(branch is Zbitmap3)
				//				return IMAGE_BITMAP;
			else if(branch is ZimageSmall2)
				return IMAGE_SMALL;
			else if(branch is ZimageLarge2)
				return IMAGE_LARGE;
			else if(branch is ZHline2)
				return HLINE;
			else if(branch is ZVline2)
				return VLINE;
			else if(branch is Zmatrix2)
				return MATRIX;				
//			else if(branch is Zfont)
//				return FONT;
			else
				throw new Error();
		}
		
		public function clear():void
		{
			atlas=new Zatlas2();
			boundingBox=new RectC();
			branch=new Zblank2();
		}
		
		public function getMc5List(dest:Vector.<String>):void
		{
			atlas.getMc5List(dest);
		}
	}
}