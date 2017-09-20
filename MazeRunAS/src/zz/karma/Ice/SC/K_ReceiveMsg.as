package zz.karma.Ice.SC{

import azura.common.collections.ZintBuffer;
import azura.karma.run.Karma;
import azura.karma.run.KarmaReaderA;
import azura.karma.run.bean.KarmaList;
import azura.karma.def.KarmaSpace;


	/**
	*<p>note: empty
	*/
	public class K_ReceiveMsg extends KarmaReaderA {
		public static const type:int = 94025674;

		public function K_ReceiveMsg(space:KarmaSpace) {
			super(space, type , 94041404);
		}

		override public function fromKarma(karma:Karma):void {
			if(karma==null) return;
			idFrom = karma.getInt(0);
			msg = karma.getBytes(1);
		}

		override public function toKarma():Karma {
			karma.setInt(0, idFrom);
			karma.setBytes(1, msg);
			return karma;
		}

		/**
		*<p>type = INT
		*<p> --note-- 
		*<p>empty
		*/
		public var idFrom:int;
		/**
		*<p>type = BYTES
		*<p> --note-- 
		*<p>empty
		*/
		public var msg:ZintBuffer;

	}
}