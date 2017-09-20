package zz.karma.JuniorEdit.SC{

import azura.common.collections.ZintBuffer;
import azura.karma.run.Karma;
import azura.karma.run.KarmaReaderA;
import azura.karma.run.bean.KarmaList;
import azura.karma.def.KarmaSpace;

	/**
	*<p>note: empty
	*/
	public class K_TestRunRet extends KarmaReaderA {
		public static const type:int = 65371169;

		public function K_TestRunRet(space:KarmaSpace) {
			super(space, type , 65371615);
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