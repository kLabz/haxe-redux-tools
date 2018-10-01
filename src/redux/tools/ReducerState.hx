package redux.tools;

import haxe.ds.Map;
import js.Object;

enum State<T> {
	Original(value:T);
	Cloned(value:T);
}

abstract ReducerState<T:{}>(State<T>) from State<T> {
	@:from
	public static function fromT<T:{}>(value:T):ReducerState<T> {
		return Original(value);
	}

	@:to
	public function get():T {
		return switch (this) {
			case Original(v), Cloned(v): v;
		};
	}

	public function hasBeenCloned():Bool {
		return switch(this) {
			case Cloned(_): true;
			case Original(_): false;
		}
	}

	// TODO: make it work with Partial<T> somehow
	public function copy(?obj:{}):ReducerState<T> {
		return Cloned(Object.assign({}, get(), obj));
	}

	// TODO: make it work with Partial<T> somehow
	inline public function assign(obj:{}):ReducerState<T> {
		this = Cloned(switch (this) {
			case Original(v):
				Object.assign({}, v, obj);

			case Cloned(v):
				Object.assign(v, obj);
		});

		return this;
	}
}

abstract ReducerMapState<TKey, TValue>(State<Map<TKey, TValue>>)
from State<Map<TKey, TValue>> {
	@:from
	public static function fromMap<TKey, TValue>(
		map:Map<TKey, TValue>
	):ReducerMapState<TKey, TValue> {
		return Original(map);
	}

	@:to
	public function getMap():Map<TKey, TValue> {
		return switch (this) {
			case Original(v), Cloned(v): v;
		};
	}

	@:arrayAccess
	public function get(key:TKey):TValue {
		return switch (this) {
			case Original(v), Cloned(v):
				v.get(key);
		};
	}

	@:arrayAccess
	inline public function set(key:TKey, value:TValue):TValue {
		this = Cloned(switch (this) {
			case Original(v):
				var v = v.copy();
				v.set(key, value);
				v;

			case Cloned(v):
				v.set(key, value);
				v;
		});

		return value;
	}

	inline public function remove(key:TKey):Bool {
		var ret = false;

		this = Cloned(switch (this) {
			case Original(v):
				var v = v.copy();
				ret = v.remove(key);
				v;

			case Cloned(v):
				ret = v.remove(key);
				v;
		});

		return ret;
	}

	public function hasBeenCloned():Bool {
		return switch(this) {
			case Cloned(_): true;
			case Original(_): false;
		}
	}

	public function copy():ReducerMapState<TKey, TValue> {
		return Cloned(getMap().copy());
	}

	inline public function assign(
		?obj:Map<TKey, TValue>
	):ReducerMapState<TKey, TValue> {
		this = Cloned(switch (this) {
			case Original(v):
				assignAll(v.copy(), obj);

			case Cloned(v):
				assignAll(v, obj);
		});

		return this;
	}

	public function has(key:TKey):Bool {
		return (this:ReducerMapState<TKey, TValue>).exists(key);
	}

	public function exists(key:TKey):Bool {
		return switch (this) {
			case Original(v), Cloned(v):
				v.exists(key);
		};
	}

	public function values():Iterator<TValue> {
		return (this: ReducerMapState<TKey, TValue>).iterator();
	}

	public function iterator():Iterator<TValue> {
		return switch (this) {
			case Original(v), Cloned(v):
				v.iterator();
		};
	}

	public function keys():Iterator<TKey> {
		return switch (this) {
			case Original(v), Cloned(v):
				v.keys();
		};
	}

	public function toString():String {
		return switch (this) {
			case Original(v):
				v.toString() + ' (original)';
			case Cloned(v):
				v.toString() + ' (cloned)';
		};
	}

	static function assignAll<TKey, TValue>(
		map1:Map<TKey, TValue>,
		map2:Map<TKey, TValue>
	):Map<TKey, TValue> {
		if (map2 != null) {
			for (k in map2.keys()) {
				map1.set(k, map2.get(k));
			}
		}

		return map1;
	}
}
