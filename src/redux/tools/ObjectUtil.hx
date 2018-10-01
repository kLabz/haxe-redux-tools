package redux.tools;

class ObjectUtil {
	public static function shallowCompare<T>(a:T, b:T):Bool {
		if (a == null && b == null) return true;
		if (a == null && b != null) return false;
		if (a != null && b == null) return false;

		var aFields = Reflect.fields(a);
		var bFields = Reflect.fields(b);
		if (aFields.length != bFields.length) return false;

		for (field in aFields)
			if (!Reflect.hasField(b, field) || Reflect.field(b, field) != Reflect.field(a, field))
				return false;

		return true;
	}
}
