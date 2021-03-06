package zz.karma.Hard.Hub{

import azura.common.collections.ZintBuffer;
import azura.karma.run.Karma;
import azura.karma.run.KarmaReaderA;
import azura.karma.run.bean.KarmaList;
import azura.karma.def.KarmaSpace;

	/**
	*<p>note: empty
	*/
	public class K_CustomMsg extends KarmaReaderA {
		public static const type:int = 18389991;

		public function K_CustomMsg(space:KarmaSpace) {
			super(space, type , 18912907);
		}

		override public function fromKarma(karma:Karma):void {
			data = karma.getBytes(0);
		}

		override public function toKarma():Karma {
			karma.setBytes(0, data);
			return karma;
		}

		/**
		*<p>type = BYTES
		*<p> --note-- 
		*<p>empty
		*/
		public var data:ZintBuffer;

	}
}