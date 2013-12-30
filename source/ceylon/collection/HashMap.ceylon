import ceylon.collection {
    Cell,
    MutableSet,
    LinkedList,
    entryStore,
    HashSet,
    MutableMap
}

"A [[MutableMap]] implemented as a hash map stored in an 
 [[Array]] of singly linked lists of [[Entry]]s. Each entry 
 is assigned an index of the array according to the hash 
 code of its key. The hash code of a key is defined by 
 [[Object.hash]].
 
 The size of the backing `Array` is called the _capacity_
 of the `HashMap`. The capacity of a new instance is 
 specified by the given [[initialCapacity]]. The capacity is 
 increased, and the entries _rehashed_, when the ratio of 
 [[size]] to capacity exceeds the given [[loadFactor]]. The 
 new capacity is the product of the current capacity and the 
 given [[growthFactor]]."
by("Stéphane Épardaud")
shared class HashMap<Key, Item>
        (initialCapacity=16, loadFactor=0.75, growthFactor=2.0, 
                entries = {})
        satisfies MutableMap<Key, Item>
        given Key satisfies Object 
        given Item satisfies Object {
    
    "The initial entries in the map."
    {<Key->Item>*} entries;
    
    "The initial capacity of the backing array."
    Integer initialCapacity;
    
    "The ratio between the number of elements and the 
     capacity which triggers a rebuild of the hash map."
    Float loadFactor;
    
    "The factor used to determine the new size of the
     backing array when a new backing array is allocated."
    Float growthFactor;
    
    "initial capacity cannot be negative"
    assert (initialCapacity>=0);
    
    "load factor must be positive"
    assert (loadFactor>0.0);
    
    "growth factor must be at least 1.0"
    assert (growthFactor>=1.0);
    
    variable value store = entryStore<Key,Item>(initialCapacity);
    variable Integer _size = 0;
    
    // Write
    
    Integer storeIndex(Object key, Array<Cell<Key->Item>?> store)
            => (key.hash % store.size).magnitude;
    
    Boolean addToStore(Array<Cell<Key->Item>?> store, Key->Item entry){
        Integer index = storeIndex(entry.key, store);
        variable value bucket = store[index];
        while(exists cell = bucket){
            if(cell.car.key == entry.key){
                // modify an existing entry
                cell.car = entry;
                return false;
            }
            bucket = cell.cdr;
        }
        // add a new entry
        store.set(index, Cell(entry, store[index]));
        return true;
    }

    void checkRehash(){
        if(_size > (store.size.float * loadFactor).integer){
            // must rehash
            value newStore = entryStore<Key,Item>((_size * growthFactor).integer);
            variable Integer index = 0;
            // walk every bucket
            while(index < store.size){
                variable value bucket = store[index];
                while(exists cell = bucket){
                    addToStore(newStore, cell.car);
                    bucket = cell.cdr;
                }
                index++;
            }
            store = newStore;
        }
    }
    
    // Add initial values
    for(entry in entries){   
        if(addToStore(store, entry)){
            _size++;
        }
    }
    checkRehash();
    
    // End of initialiser section
    
    shared actual Item? put(Key key, Item item){
        Integer index = storeIndex(key, store);
        value entry = key->item;
        variable value bucket = store[index];
        while(exists cell = bucket){
            if(cell.car.key == key){
                Item oldValue = cell.car.item;
                // modify an existing entry
                cell.car = entry;
                return oldValue;
            }
            bucket = cell.cdr;
        }
        // add a new entry
        store.set(index, Cell(entry, store[index]));
        _size++;
        checkRehash();
        return null;
    }
    
    "Adds a collection of key/value mappings to this map, 
     may be used to change existing mappings"
    shared actual void putAll({<Key->Item>*} entries){
        for(entry in entries){
            if(addToStore(store, entry)){
                _size++;
            }
        }
        checkRehash();
    }
    
    
    "Removes a key/value mapping if it exists"
    shared actual Item? remove(Key key){
        Integer index = storeIndex(key, store);
        variable value bucket = store[index];
        variable value prev = null of Cell<Key->Item>?;
        while(exists Cell<Key->Item> cell = bucket){
            if(cell.car.key == key){
                // found it
                if(exists last = prev){
                    last.cdr = cell.cdr;
                }else{
                    store.set(index, cell.cdr);
                }
                _size--;
                return cell.car.item;
            }
            prev = cell;
            bucket = cell.cdr;
        }
        return null;
    }
    
    "Removes every key/value mapping"
    shared actual void clear(){
        variable Integer index = 0;
        // walk every bucket
        while(index < store.size){
            store.set(index++, null);
        }
        _size = 0;
    }
    
    // Read
    
    size => _size;
    
    shared actual Item? get(Object key) {
        if(empty){
            return null;
        }
        Integer index = storeIndex(key, store);
        variable value bucket = store[index];
        while(exists cell = bucket){
            if(cell.car.key == key){
                return cell.car.item;
            }
            bucket = cell.cdr;
        }
        return null;
    }
    
    shared actual Collection<Item> values {
        value ret = LinkedList<Item>();
        variable Integer index = 0;
        // walk every bucket
        while(index < store.size){
            variable value bucket = store[index];
            while(exists cell = bucket){
                ret.add(cell.car.item);
                bucket = cell.cdr;
            }
            index++;
        }
        return ret;
    }
    
    shared actual Set<Key> keys {
        value ret = HashSet<Key>();
        variable Integer index = 0;
        // walk every bucket
        while(index < store.size){
            variable value bucket = store[index];
            while(exists cell = bucket){
                ret.add(cell.car.key);
                bucket = cell.cdr;
            }
            index++;
        }
        return ret;
    }
    
    shared actual Map<Item,Set<Key>> inverse {
        value ret = HashMap<Item,MutableSet<Key>>();
        variable Integer index = 0;
        // walk every bucket
        while(index < store.size){
            variable value bucket = store[index];
            while(exists cell = bucket){
                if(exists keys = ret[cell.car.item]){
                    keys.add(cell.car.key);
                }else{
                    value k = HashSet<Key>();
                    ret.put(cell.car.item, k);
                    k.add(cell.car.key);
                }
                bucket = cell.cdr;
            }
            index++;
        }
        return ret;
    }
    
    shared actual Iterator<Key->Item> iterator() {
        // FIXME: make this faster with a size check
        object iter satisfies Iterator<Key->Item> {
            variable Integer index = 0;
            variable value bucket = store[index];
            
            shared actual <Key->Item>|Finished next() {
                // do we need a new bucket?
                if(!bucket exists){
                    // find the next non-empty bucket
                    while(++index < store.size){
                        bucket = store[index];
                        if(bucket exists){
                            break;
                        }
                    }
                }
                // do we have a bucket?
                if(exists bucket = bucket){
                    value car = bucket.car;
                    // advance to the next cell
                    this.bucket = bucket.cdr;
                    return car;
                }
                return finished;
            }
        }
        return iter;
    }
    
    shared actual Integer count(Boolean selecting(Key->Item element)) {
        variable Integer index = 0;
        variable Integer count = 0;
        // walk every bucket
        while(index < store.size){
            variable value bucket = store[index];
            while(exists cell = bucket){
                if(selecting(cell.car)){
                    count++;
                }
                bucket = cell.cdr;
            }
            index++;
        }
        return count;
    }
    
    shared actual String string {
        variable Integer index = 0;
        StringBuilder ret = StringBuilder();
        ret.append("{");
        variable Boolean first = true;
        // walk every bucket
        while(index < store.size){
            variable value bucket = store[index];
            while(exists cell = bucket){
                if(!first){
                    ret.append(", ");
                }else{
                    first = false;
                }
                ret.append(cell.car.key.string);
                ret.append("->");
                ret.append(cell.car.item.string);
                bucket = cell.cdr;
            }
            index++;
        }
        ret.append("}");
        return ret.string;
    }
    
    shared actual Integer hash {
        variable Integer index = 0;
        variable Integer hash = 17;
        // walk every bucket
        while(index < store.size){
            variable value bucket = store[index];
            while(exists cell = bucket){
                hash = hash * 31 + cell.car.hash;
                bucket = cell.cdr;
            }
            index++;
        }
        return hash;
    }
    
    shared actual Boolean equals(Object that) {
        if(is Map<Object,Object> that,
            size == that.size){
            variable Integer index = 0;
            // walk every bucket
            while(index < store.size){
                variable value bucket = store[index];
                while(exists cell = bucket){
                    if(exists item = that.get(cell.car.key)){
                        if(item != cell.car.item){
                            return false;
                        }
                    }else{
                        return false;
                    }
                    bucket = cell.cdr;
                }
                index++;
            }
            return true;
        }
        return false;
    }
    
    shared actual MutableMap<Key,Item> clone {
        value clone = HashMap<Key,Item>();
        clone._size = _size;
        clone.store = entryStore<Key,Item>(store.size);
        variable Integer index = 0;
        // walk every bucket
        while(index < store.size){
            if(exists bucket = store[index]){
                clone.store.set(index, bucket.clone); 
            }
            index++;
        }
        return clone;
    }
    
    shared actual Boolean contains(Object element) {
        variable Integer index = 0;
        // walk every bucket
        while(index < store.size){
            variable value bucket = store[index];
            while(exists cell = bucket){
                if(cell.car.item == element){
                    return true;
                }
                bucket = cell.cdr;
            }
            index++;
        }
        return false;
    }
    
}
