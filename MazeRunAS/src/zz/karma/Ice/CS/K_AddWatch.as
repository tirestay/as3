package zz.karma.Ice.CS{

import azura.common.collections.ZintBuffer;
import azura.karma.run.Karma;
import azura.karma.run.KarmaReaderA;
import azura.karma.run.bean.KarmaList;
import azura.karma.def.KarmaSpace;

import zz.karma.Ice.K_Watch;

	/**
	*<p>note: empty
	*/
	public class K_AddWatch extends KarmaReaderA {
		public static const type:int = 93522544;

		public function K_AddWatch(space:KarmaSpace) {
			super(space, type , 93525173);
		watch=new K_Watch(space);
		}

		override public function fromKarma(karma:Karma):void {
			if(karma==null) return;
			watch.fromKarma(karma.getKarma(0));
		}

		override public function toKarma():Karma {
			if(watch != null)
				karma.setKarma(0, watch.toKarma());
			return karma;
		}

		/**
		*<p>type = KARMA
		*<p>[Watch] empty
		*<p> --note-- 
		*<p>empty
		*/
		public var watch:K_Watch;

		/**
		*Watch
		*/
		public static const T_Watch:int = 93513828;
	}
}