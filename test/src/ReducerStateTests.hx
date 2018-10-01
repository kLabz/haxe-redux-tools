package;

import buddy.SingleSuite;
import redux.tools.ReducerState;

using buddy.Should;
using redux.tools.ObjectUtil;

typedef TestBaseState = {
	var message:String;
	var values:Array<String>;
};

typedef TestState = ReducerState<TestBaseState>;
// typedef TestMapState = ReducerMapState<String, Int>;

class ReducerStateTests extends SingleSuite {
	public function new() {
		describe("ReducerState<T>", {
			it("should implement copy()", {
				var state:TestState = {message: "test", values: []};

				state.copy().hasBeenCloned().should.be(true);
				state.hasBeenCloned().should.be(false);

				// Reference of value should have changed
				state.copy().get().should.not.be(state);

				// But the actual value should be the same
				state.copy().get().shallowCompare(state).should.be(true);
			});

			it("should implement assign()", {
				var originalState:TestBaseState = {message: "test", values: []};
				var state:TestState = originalState;

				state.hasBeenCloned().should.be(false);

				state.assign({message: "test assign"}).get().message.should.be("test assign");
				state.hasBeenCloned().should.be(true);
				originalState.message.should.be("test");

			});
		});

		describe("ReducerMapState<TKey, TValue>", {
			it("should implement copy()", {
				var map:Map<String, Int> = ["test" => 42];
				var state:ReducerMapState<String, Int> = map;
				var newState = state.copy();

				state.hasBeenCloned().should.be(false);
				newState.should.not.be(state);

				newState.getMap().set("test1", 1);
				newState.get("test1").should.be(1);
				state.has("test1").should.be(false);
			});

			it("should implement assign()", {
				var map:Map<String, Int> = ["test" => 42];
				var state:ReducerMapState<String, Int> = map;

				state.hasBeenCloned().should.be(false);
				state.exists("test").should.be(true);
				state.has("test").should.be(true);

				state.assign([
					"test1" => 1
				]);

				state.hasBeenCloned().should.be(true);
				state.get("test").should.be(42);

				state.exists("test1").should.be(true);
				state.has("test1").should.be(true);
				state.get("test1").should.be(1);

				state.exists("test2").should.be(false);
				state.has("test2").should.be(false);

				// Original object should not be changed
				map.exists("test1").should.be(false);
				map.get("test").should.be(42);
			});

			it("should implement get() / set()", {
				var map:Map<String, Int> = ["test" => 42];
				var state:ReducerMapState<String, Int> = map;

				state.get("test").should.be(42);
				state.hasBeenCloned().should.be(false);

				state.set("test", 1);
				state.hasBeenCloned().should.be(true);
				state.get("test").should.be(1);

				state.set("test1", 2);
				state.hasBeenCloned().should.be(true);
				state.get("test").should.be(1);
				state.get("test1").should.be(2);

				// Original object should not be changed
				map.exists("test1").should.be(false);
				map.get("test").should.be(42);
			});

			it("should support array access (read + write)", {
				var map:Map<String, Int> = ["test" => 42];
				var state:ReducerMapState<String, Int> = map;

				state["test"].should.be(42);
				state.hasBeenCloned().should.be(false);

				state["test"] = 1;
				state.hasBeenCloned().should.be(true);
				state.get("test").should.be(1);

				state["test1"] = 2;
				state.hasBeenCloned().should.be(true);
				state.get("test").should.be(1);
				state.get("test1").should.be(2);

				// Original object should not be changed
				map.exists("test1").should.be(false);
				map.get("test").should.be(42);
			});

			it("should implement remove()", {
				var map:Map<String, Int> = ["test" => 42, "test1" => 1];
				var state:ReducerMapState<String, Int> = map;

				state.remove("test");
				state.hasBeenCloned().should.be(true);
				state.exists("test").should.be(false);
				state.exists("test1").should.be(true);

				state.remove("test1");
				state.exists("test1").should.be(false);

				// Original object should not be changed
				map.get("test").should.be(42);
				map.get("test1").should.be(1);
			});

			it("should implement iterator() / values()", {
				var map:Map<String, Int> = [
					"test" => 0,
					"test1" => 1,
					"test2" => 2,
					"test3" => 3,
				];

				var state:ReducerMapState<String, Int> = map;

				var values = [0, 1, 2, 3];
				for (v in state) v.should.be(values.shift());

				var values = [0, 1, 2, 3];
				for (v in state.iterator()) v.should.be(values.shift());
			});

			it("should implement keys()", {
				var map:Map<String, Int> = [
					"test" => 0,
					"test1" => 1,
					"test2" => 2,
					"test3" => 3,
				];

				var state:ReducerMapState<String, Int> = map;

				var keys = ["test", "test1", "test2", "test3"];
				for (k in state.keys()) k.should.be(keys.shift());
			});

			it("should implement toString()", {
				var map:Map<String, Int> = ["test" => 42];
				var mapStr = map.toString();

				var state:ReducerMapState<String, Int> = map;
				state.toString().should.be(mapStr + ' (original)');

				state.assign();
				state.toString().should.be(mapStr + ' (cloned)');
			});
		});
	}
}
