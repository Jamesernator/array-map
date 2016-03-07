# ArrayMap

## Description

ArrayMap is a ES6 Map-like object designed for use where arrays are needed to act as map keys by array-values rather than array identity for example

```javascript
ArrayMap = require('es6-array-map')
arrayMap = new ArrayMap();
arrayMap.set([1,2,3], 10);
console.log(arrayMap.get([1,2,3])); // prints 10 even though [1,2,3] has
                                    // different identity to the list set with
```

## Install
```npm install github:Jamesernator/es6-array-map```


## Documentation
ArrayMap has an identical set of available methods as EcmaScript 2016 Maps provide, the only major differences are the key equality and order of iteration.

### Key Equality
The main difference from ES6 maps is that keys are equal if the values of the arrays are equal.
For example with keys ``a=[1,2,3];`` and ``b=[1,2,3];`` then these are considered equal. Sub-arrays and objects in the array however are not considered by values so ``a=[1,2,{}];`` and ``b=[1,2,{}]`` are not equal as each ```{}``` has a different identity.

### Order of Iteration
Due to how the ArrayMap is stored (as a tree of values) we don't iterate over the values in insertion order, instead they're iterated using tree-search.

### Properties

#### ArrayMap.length
For sake of consistency with ES6 Maps ArrayMap.length has length 0.

#### ArrayMap.prototype
Its the prototype for ArrayMap objects, feel free to extend it.

### Methods

#### ArrayMap.prototype.clear()
Removes all [arrayKey, value] pairs from the ArrayMap object.
```javascript
var map = new ArrayMap();
map.set([1,2,3], 'cats');
map.set([1,2], 12);

map.get([1,2,3]); // 'cats'
map.has([1,2,3]); // true

map.size; // 2
map.clear();

map.has([1,2,3]); // false
map.get([1,2,3]); // undefined
map.size; // 0
```


#### ArrayMap.prototype.delete(arrayKey)
Removes a value associated with arrayKey. ArrayMap.prototype.has(arrayKey) will return false afterwards.
```javascript
var map = new ArrayMap();
map.set([1,2,3], 10);

map.get([1,2,3]); // 10
map.has([1,2,3]); // true

map.delete([1,2,3]); // true
map.delete([2,3]); // false as there wasn't any value associated with [2,3]

map.has([1,2,3]); // false
map.get([1,2,3]); // undefined
```

Be wary of using array elements by value though:
```javascript
var map = new ArrayMap();
map.set([1,2,{}], 10);
map.size; // 1

map.delete([1,2,{}]); // false as {} isn't the same object as originally used
                      // in .set
map.size; // 1
```

#### ArrayMap.prototype.entries()
Returns a new Iterator that gives [arrayKey, value] pairs for each element of the ArrayMap. Unlike ES6 Maps this is not in insertion order but rather using depth-first-search (yielding as they're seen).

```javascript
var map = new ArrayMap();
map.set([1,2], 10);
map.set([], 12);
map.set([1,2,3], 30);
map.set([2,3], 40);
map.set(['cats', 'hats'], 40);

Array.from(map.entries);
    // [
    //   [ [], 12 ], // Shortest comes first
    //   [ [ 1, 2 ], 10 ], // Depth-first search on subkeys happens next
    //   [ [ 1, 2, 3 ], 30 ], // So [1,2,3] comes next as it follows from [1,2]
    //   [ [ 2, 3 ], 40 ],
    //   [ ['cats', 'hats'], 40] // Any objects make valid keys in any map
    // ]
```

#### ArrayMap.prototype.forEach(callback[, thisArg])
Calls callback once for each key-value pair present in the Map object, in insertion order. If a thisArg parameter is provided to forEach, it will be used as the this value for each callback.
```javascript
var map = new ArrayMap();
map.set([1,2,3], 12);
map.set([], 10);
map.set([11], 5);

var total = 0;
map.forEach(function(value, key, arrayMap) {
    total = total + value;
});
total; // 27
```

#### ArrayMap.prototype.get(arrayKey)
Returns the value associated with arrayKey or undefined if there is none.
```javascript
var map = new ArrayMap();
map.set([1,2,3], 12);
map.set([], 10);

map.get([1,2,3]); // 12
map.get([]); // 10
map.get([11,12]); // undefined

// undefined is still a valid value though
map.set([1,2], undefined);
map.get([1,2]); // undefined
// so check with .has(arrayKey) first if undefined is a valid value
map.has([1,2]); // true
map.has([110,12]); // false

map.set(['cats', 12], {hats: /sats/}); // Keys and values can be types you want
map.get(['cats', 12]); // {hats: /sats/}, primitives are recommended for keys though
                       // as arrayKey elements are compared using ES6 Map key equality

```

Note that only the arrayKey itself is considered exempt from ES6 Map equality, the internal entries aren't so the following doesn't work:
```javascript
var map = new ArrayMap();
var objectA = {};
var objectB = {};

map.set([1, objectA], 12);
map.get([1, objectB]); // undefined as [1, objectA] is a different key to
                       // [1, objectB]

map.set([1, NaN], 10);
map.get([1, NaN]); // 10, as while NaN !== NaN, ES6 map equality is used
                   // for entries within the arrayKey
```

#### ArrayMap.prototype.has(arrayKey)
Returns true if there is a value associated with arrayKey, false otherwise.
```javascript
var map = new ArrayMap();
map.set([1,2,3], 12);

map.has([1,2,3]); // true
map.get([1,2,3]); // 12

map.set([2,3], undefined);
map.has([2,3]); // true, undefined is still a valid value for a key to
                // be associated with
map.has([999, 999]); // false
map.get([999,999]) // undefined, get will still return undefined so you
                   // you may need to explicitly check .has(arrayKey) before
                   // using .get(arrayKey) if undefined is a valid value
```

#### ArrayMap.prototype.keys()
Returns an iterator of all keys of the ArrayMap object, the keys are iterated in depth-first-search order (yielding as seen so smaller keys come before the corresponding larger subkeys).
```javascript
var map = new ArrayMap();
map.set([1,2,3], 12);
map.set([1,2], 10);
map.set([], 'cats');
map.set([4,5], 1001);

Array.from(map.keys()); // [ [], [ 1, 2 ], [ 1, 2, 3 ], [ 4, 5 ] ]
```

#### ArrayMap.prototype.set(arrayKey, value)
Sets the value for the given arrayKey in the map, if two arrayKeys have identical elements then they will be set to the same value:
```javascript
var map = new ArrayMap();
map.set([1,2,3], 12);
map.get([1,2,3]); // 12

map.set([1,2,3], -12); // Setting to an equal array will override original values
map.get([1,2,3]); // -12

var objectA = {};
var objectB = {};
map.set([10, objectA], 20);
map.get([10, objectB]); // undefined as [10, objectA] isn't the same key
                        // as [10, objectB]
map.get([10, objectA]); // 20, if you still can make the arrayKey you can still
                        // access the element

map.set(['cats', 10, {}, new ArrayMap()], 24); // Any objects can be used as parts
                                               // of a key, but its recommended to use primitives
                                               // as primitives are easy to recreate

map.set([], 42); // The empty array is also a valid key
map.get([]); // 42

map.set([NaN], 12);
map.get([NaN]); // 12, although NaN !== NaN elements of the arrayKey are considered
                // equal by ES6 Map key equality
```

#### ArrayMap.prototype.values()
Returns an Iterator of values of the map.
```javascript
var map = new ArrayMap();
map.set([1,2,3], 12);
map.set([3,4], 16);
map.set([], 200);
map.set([12,13], 'llamas');

Array.from(map.keys()); // [200, 12, 16, 'llamas']
```

#### ArrayMap.prototype\[@@iterator\]()
Returns an Iterator of [key, value] pairs, this is equivalent to ArrayMap.prototype.entries()


### Credits
Documentation based off Mozilla Developer Network's Map documentation <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map>

Original idea based on <http://stackoverflow.com/questions/21838436/map-using-tuples-or-objects>
