"use strict"

iterMap = (iterable, func) ->
    ### This applies a function to each item in an iterable ###
    iterator = iterable[Symbol.iterator]()
    while true
        {done, value} = iterator.next()
        if done
            return value
        yield func(value)

iterEach = (iterable, func) ->
    ### Calls a given function on each value of the iterable ###
    iterator = iterable[Symbol.iterator]()
    while true
        {done, value} = iterator.next()
        if done
            return value
        func(value)

iterJoin = (iterable, generatorFunc) ->
    ### This yields all values from the generator function
        applied to each of the values in iterable,
        e.g.
        gen = ->
            yield from join [[1,2], [3,4]], (sublist) ->
                yield from sublist

        Array.from(gen) # [1,2,3,4]
    ###
    iterator = iterable[Symbol.iterator]()
    while true
        {done, value} = iterator.next()
        if done
            return value
        yield from generatorFunc(value)

class ArrayMap
    constructor: (iterable=null) ->
        @size = 0
        @subMaps = null
        @value = undefined
        @hasValue = false
        if iterable?
            iterEach iterable, ([arrayKey, value]) =>
                @set(arrayKey, value)

    clear: ->
        ### Removes everything from the arrayMap ###
        @size = 0
        @subMaps = null
        @value = undefined
        @hasValue = false

    delete: (arrayKey) ->
        ### Removes a given arrayKey from the arrayMap, if it existed
            return true, else return false
        ###
        if arrayKey.length is 0
            # Base case is just to remove the value
            if @hasValue
                @size -= 1
            @value = undefined
            @hasValue = false
            return true
        else unless @subMaps?
            # If there's no subMaps to search just return false
            return false
        else unless @subMaps.has(arrayKey[0])
            # If there's no associated subMap for arrayKey[0] then we
            # definitely don't have a value to delete
            return false
        else
            # Proceed recursively updating changes in the current subTree
            previousSize = @subMaps.get(arrayKey[0]).size
            # Get the result of deletion for returning
            result = @subMaps.get(arrayKey[0]).delete(arrayKey[1...])
            newSize = @subMaps.get(arrayKey[0]).size
            # Update size with any changes from subMap
            @size += newSize - previousSize
            if @subMaps.get(arrayKey[0]).size is 0
                # If we don't have any more nodes on the subTree just delete
                # the subKey
                @subMaps.delete(arrayKey[0])
            if @subMaps.size is 0
                # If there's no remaining subMaps just delete the subMap
                @subMaps = null

            return result

    entries: ->
        ### Returns an iterator of entries in the arrayMap ###
        if @hasValue
            yield [[], @value] # Base case
        if @subMaps?
            yield from iterJoin @subMaps, ([key, subMap]) =>
                subEntries = @subMaps.get(key).entries()
                yield from iterMap subEntries, ([subKey, value]) =>
                    return [[key].concat(subKey), value]

    forEach: (callback, thisArg) ->
        ### Calls the callback (bound to thisArg), on each value, key pair
            of the ArrayMap
        ###
        _callback = callback.bind(thisArg)
        iterEach @entries(), ([key, value]) =>
            _callback(value, key, this)

    get: (arrayKey) ->
        ### Returns the value associated with a given arrayKey
            returns undefined if we don't have such a value
        ###
        if arrayKey.length is 0
            # Base case is @value, we don't need to check @hasValue as
            # @value will store undefined anyway
            return @value
        else unless @subMaps?
            # If we don't have any subMaps then there's no value
            return undefined
        else unless @subMaps.has(arrayKey[0])
            # If there's no subMap for arrayKey[0] then we definitely
            # don't have the value
            return undefined
        else
            # Proceed down recursively
            return @subMaps.get(arrayKey[0]).get(arrayKey[1...])

    has: (arrayKey) ->
        ### Returns true if there is a value associated with arrayKey,
            false otherwise
        ###
        if arrayKey.length is 0
            # Base case is this node
            return @hasValue
        else unless @subMaps?
            # If there's no subMaps then we definitely don't have it
            return false
        else unless @subMaps.has(arrayKey[0])
            # If we don't have an appropriate subMap then we definitely don't
            # have it either
            return false
        else
            # Traverse recursively to find it
            return @subMaps.get(arrayKey[0]).has(arrayKey[1...])

    keys: ->
        ### Returns an iterator of keys of the arrayMap ###
        yield from iterMap @entries(), ([key, _]) ->
            return key

    set: (arrayKey, value) ->
        ### Associates in the map the given arrayKey with the given value ###
        if arrayKey.length is 0
            # If arrayKey is empty consider this node
            unless @hasValue
                @size += 1
            @value = value
            @hasValue = true
        else
            # Else proceed recursively
            unless @subMaps?
                # Create a new subMap collection if neccessary
                @subMaps = new Map()

            unless @subMaps.has(arrayKey[0])
                # If we don't have an existing subMap create it
                @subMaps.set(arrayKey[0], new ArrayMap())


            previousSize = @subMaps.get(arrayKey[0]).size
            # Update the arrayMap recursively
            @subMaps.get(arrayKey[0]).set(arrayKey[1...], value)
            ## Get new size of subMap and update current size appropriately
            newSize = @subMaps.get(arrayKey[0]).size
            @size += newSize - previousSize

        return this

    values: ->
        ### Returns an iterator of values of the arrayMap ###
        yield from iterMap @entries(), ([_, value]) ->
            return value

    @::[Symbol.iterator] = ->
        ### Returns an iterator of [key, value] pairs ###
        return @entries()

module.exports = ArrayMap
