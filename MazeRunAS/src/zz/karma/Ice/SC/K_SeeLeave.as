package zz.karma.Ice.SC{

import azura.common.collections.ZintBuffer;
import azura.karma.run.Karma;
import azura.karma.run.KarmaReaderA;
import azura.karma.run.bean.KarmaList;
import azura.karma.def.KarmaSpace;


	/**
	*<p>note: empty
	*/
	public class K_SeeLeave extends KarmaReaderA {
		public static const type:int = 93524496;

		public function K_SeeLeave(space:KarmaSpace) {
			super(space, type , 93525178);
		}

		override public function fromKarma(karma:Karma):void {
			if(karma==null) return;
			id = karma.getInt(0);
		}

		override public function toKarma():Karma {
			karma.setInt(0, id);
			return karma;
		}

		/**
		*<p>type = INT
		*<p> --note-- 
		*<p>empty
		*/
		public var id:int;

	}
}