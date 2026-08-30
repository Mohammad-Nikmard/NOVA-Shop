enum CacheStorageType {
  memory('Memory'),
  persistent('Persistent');

  final String key;

  const CacheStorageType(this.key);
}
