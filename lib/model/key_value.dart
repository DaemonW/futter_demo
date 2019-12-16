class KeyValueItem {
  String _key;
  Object _val;

  KeyValueItem(String key, Object val) {
    this._key = key;
    this._val = val;
  }

  String get key {
    return this._key;
  }

  Object get value {
    return this._val;
  }
}
