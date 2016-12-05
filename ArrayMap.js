#!/usr/bin/env babel-node
function id(x) {
    return x
}

export default class ArrayMap {
    constructor(iterable=null, serialize=id) {
        /*  Creates an ArrayMap object with optional serialize that will
            be called on every single key entered
        */
        this.size = 0
        this.subMaps = new Map()
        this.value = undefined
        this.hasValue = false
        this.serialize = serialize
        if (iterable != null) {
            for (const [arrayKey, value] of iterable) {
                this.set(arrayKey, value)
            }
        }
    }

    clear() {
        /* Removes all elements from the ArrayMap */
        this.size = 0
        this.subMaps = new Map()
        this.value = undefined
        this.hasValue = false
    }

    delete(arrayKey) {
        /* Removes a item from the ArrayMap */
        return this._delete(this.serialize(arrayKey))
    }

    /*eslint-disable complexity*/
    _delete(arrayKey) {
        const [first, ...rest] = arrayKey
        if (arrayKey.length === 0) {
            if (this.hasValue) {
                this.size -= 1
                this.value = undefined
                this.hasValue = false
                return true
            } else {
                return false
            }
        } else if (!this.subMaps.has(first)) {
            return false
        } else {
            const subMap = this.subMaps.get(first)
            const result = subMap._delete(rest)
            if (result) {
                this.size -= 1
                if (subMap.size === 0) {
                    this.subMaps.delete(first)
                }
            }
            return result
        }
    }
    /*eslint-enable complexity*/

    *entries() {
        /*  Yields successively values from the ArrayMap in
            depth first search order
        */
        if (this.hasValue) {
            yield [[], this.value]
        }
        for (const [key, subMap] of this.subMaps) {
            for (const [arrayKey, value] of subMap.entries()) {
                yield [[key, ...arrayKey], value]
            }
        }
    }

    forEach(callback, thisValue=null) {
        /* Applies the callback to each value in the ArrayMap */
        for (const [key, value] of this.entries()) {
            Reflect.apply(callback, thisValue, [value, key, this])
        }
    }

    get(arrayKey) {
        /* Returns the value for a given arrayKey, otherwise undefined */
        return this._get(this.serialize(arrayKey))
    }

    _get(arrayKey) {
        const [first, ...rest] = arrayKey
        if (arrayKey.length === 0) {
            return this.value
        } else if (!this.subMaps.has(first)) {
            return undefined
        } else {
            return this.subMaps.get(first)._get(rest)
        }
    }

    has(arrayKey) {
        return this._has(this.serialize(arrayKey))
    }

    _has(arrayKey) {
        const [first, ...rest] = arrayKey
        if (arrayKey.length === 0) {
            return this.hasValue
        } else if (!this.subMaps.has(first)) {
            return false
        } else {
            return this.subMaps.get(first)._get(rest)
        }
    }

    *keys() {
        if (this.hasValue) {
            yield []
        }
        for (const [key, subMap] of this.subMaps) {
            for (const [arrayKey] of subMap.entries()) {
                yield [key, ...arrayKey]
            }
        }
    }

    set(arrayKey, value) {
        /* Sets the value of an arrayKey to the given value */
        return this._set(this.serialize(arrayKey), value)
    }

    _set(arrayKey, value) {
        if (arrayKey.length === 0) {
            if (!this.hasValue) {
                this.size += 1
            }
            this.value = value
            this.hasValue = true
        } else {
            const [first, ...rest] = arrayKey
            if (!this.subMaps.has(first)) {
                this.subMaps.set(first, new ArrayMap(null))
            }

            const subMap = this.subMaps.get(first)
            const previousSize = subMap.size
            subMap._set(rest, value)
            const newSize = subMap.size
            this.size += newSize - previousSize
        }
        return this
    }

    [Symbol.iterator]() {
        return this.entries()
    }
}
