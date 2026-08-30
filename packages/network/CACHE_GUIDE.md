# Network Cache Management System

## Overview

The Network package now includes a comprehensive URL-based caching system that allows you to cache API responses selectively. The cache system is designed with SOLID principles and provides flexible, persistent storage that survives app restarts.

## Key Features

✅ **URL-based Selective Caching** - Only cache specific endpoints you choose  
✅ **Persistent Storage** - Cache survives app restarts  
✅ **Configurable Durations** - Default 20 minutes, customizable per request  
✅ **Force Refresh** - Bypass cache when needed  
✅ **Cache Invalidation** - Remove specific or pattern-based cache entries  
✅ **Cache Statistics** - Monitor cache usage and performance  
✅ **Custom Validation** - Add custom logic to validate cached data  
✅ **No Size Limits** - Unlimited cache storage  

## Quick Start

### 1. Initialize with Cache Enabled

```dart
import 'package:network/network.dart';

void main() async {
  // Initialize network package with caching enabled (default)
  await NetworkLocator.init(enableCache: true);
  
  // Get API client
  final apiClient = networkLocator.get<ApiClient>();
}
```

### 2. Basic Cached Requests

```dart
// Cached GET request with default 20-minute duration
final response = await apiClient.get(
  '/users/profile',
  cacheOptions: const CacheOptions.withDefault(),
);

// Non-cached request (no cacheOptions = no caching)
final response = await apiClient.get('/users/profile');
```

### 3. Force Refresh

```dart
// Bypass cache and get fresh data
final response = await apiClient.get(
  '/users/profile',
  cacheOptions: const CacheOptions.withDefault(),
  forceRefresh: true,
);
```

## Cache Options

### Predefined Durations

```dart
// Default duration (20 minutes)
const CacheOptions.withDefault()

// Short-term cache (5 minutes)
const CacheOptions.shortTerm()

// Long-term cache (2 hours)
const CacheOptions.longTerm()

// Custom duration
const CacheOptions(duration: Duration(hours: 1))
```

### Cache Key Suffixes

Use cache key suffixes to create context-specific cache entries for the same endpoint:

```dart
// Cache user preferences for different themes
await apiClient.get(
  '/user/preferences',
  cacheOptions: const CacheOptions.withDefault(keySuffix: 'theme_dark'),
);

await apiClient.get(
  '/user/preferences', 
  cacheOptions: const CacheOptions.withDefault(keySuffix: 'theme_light'),
);
```

### Custom Validation

Add custom logic to validate if cached data is still relevant:

```dart
final response = await apiClient.get(
  '/user/notifications',
  cacheOptions: CacheOptions(
    duration: const Duration(minutes: 30),
    validator: (cachedData) {
      // Return true if cache is valid, false to invalidate
      if (cachedData is Map<String, dynamic>) {
        return cachedData.containsKey('notifications');
      }
      return false;
    },
  ),
);
```

## Cache Management

### Invalidate Specific Cache

```dart
// Invalidate cache for a specific endpoint
await NetworkLocator.invalidateCache('/users/profile');

// Invalidate with query parameters
await NetworkLocator.invalidateCache(
  '/products',
  queryParameters: {'category': 'electronics'},
);
```

### Clear All Cache

```dart
// Clear all cached data
final clearedCount = await NetworkLocator.clearAllCache();
print('Cleared $clearedCount cache entries');
```

### Cache Statistics

```dart
final stats = await NetworkLocator.getCacheStats();
if (stats != null) {
  print('Total entries: ${stats.totalEntries}');
  print('Valid entries: ${stats.validEntries}');
  print('Expired entries: ${stats.expiredEntries}');
  print('Total size: ${stats.totalSizeBytes} bytes');
}
```

## Usage Patterns

### Service Layer Integration

```dart
class UserService {
  final ApiClient _apiClient;
  
  UserService(this._apiClient);
  
  // Cache user profile for 15 minutes
  Future<NetworkResponse> getUserProfile(String userId) {
    return _apiClient.get(
      '/users/$userId',
      cacheOptions: const CacheOptions(duration: Duration(minutes: 15)),
    );
  }
  
  // Force refresh user data
  Future<NetworkResponse> refreshUserProfile(String userId) {
    return _apiClient.get(
      '/users/$userId',
      cacheOptions: const CacheOptions.withDefault(),
      forceRefresh: true,
    );
  }
}
```

### Cache Configuration Constants

```dart
class CacheConfigurations {
  // User data - medium duration
  static const userDataCache = CacheOptions(duration: Duration(minutes: 15));
  
  // App configuration - long duration  
  static const appConfigCache = CacheOptions(duration: Duration(hours: 6));
  
  // Dynamic content - short duration
  static const dynamicContentCache = CacheOptions(duration: Duration(minutes: 5));
  
  // Reference data - very long duration
  static const referenceDataCache = CacheOptions(duration: Duration(days: 1));
}

// Usage
final response = await apiClient.get(
  '/app/config',
  cacheOptions: CacheConfigurations.appConfigCache,
);
```

## HTTP Methods Support

### GET Requests (Most Common)

```dart
final response = await apiClient.get(
  '/products',
  queryParameters: {'category': 'electronics'},
  cacheOptions: const CacheOptions(duration: Duration(hours: 1)),
);
```

### POST Requests (For Idempotent Operations)

```dart
// Cache search results
final response = await apiClient.post(
  '/search',
  {'query': 'flutter', 'filters': ['mobile']},
  cacheOptions: const CacheOptions(duration: Duration(minutes: 10)),
);
```

### PUT/DELETE Requests

```dart
// Rarely cached, but supported
final response = await apiClient.put(
  '/user/settings',
  {'theme': 'dark'},
  cacheOptions: const CacheOptions.shortTerm(),
);
```

## Cache Key Generation

Cache keys are automatically generated based on:
- Base URL
- Endpoint path
- Query parameters (sorted for consistency)
- HTTP method (for non-GET requests)
- Optional key suffix

Example cache key generation:
```
URL: https://api.example.com/users/123?include=profile&sort=name
Method: GET
Suffix: theme_dark

Generated Key: network_cache_a1b2c3d4e5f6...
```

## Best Practices

### 1. Choose Appropriate Cache Durations

- **Static/Reference Data**: Hours to days
- **User Data**: 10-30 minutes  
- **Dynamic Content**: 1-10 minutes
- **Search Results**: 5-15 minutes

### 2. Use Cache Key Suffixes Strategically

```dart
// Good: Context-specific caching
await apiClient.get(
  '/user/dashboard',
  cacheOptions: CacheOptions.withDefault(keySuffix: 'role_admin'),
);

// Good: User-specific caching  
await apiClient.get(
  '/notifications',
  cacheOptions: CacheOptions.withDefault(keySuffix: 'user_$userId'),
);
```

### 3. Cache Invalidation Strategy

```dart
// Invalidate related cache after updates
await apiClient.put('/user/profile', updatedData);
await NetworkLocator.invalidateCache('/user/profile');
await NetworkLocator.invalidateCache('/user/dashboard');
```

### 4. Monitor Cache Performance

```dart
// Periodic cache cleanup and monitoring
Future<void> performCacheCleanup() async {
  final stats = await NetworkLocator.getCacheStats();
  
  if (stats != null && stats.expiredEntries > 100) {
    // Clear expired entries if too many
    await NetworkLocator.clearAllCache();
  }
}
```

## Architecture

The cache system follows SOLID principles:

- **Single Responsibility**: Each component has a focused purpose
- **Open/Closed**: Easy to extend with new cache strategies
- **Liskov Substitution**: Cache implementations are interchangeable
- **Interface Segregation**: Clean, focused interfaces
- **Dependency Inversion**: Depends on abstractions, not concretions

### Core Components

1. **CacheOptions**: Configuration for cache behavior
2. **CacheEntry**: Represents cached data with metadata
3. **CacheManager**: Abstract interface for cache operations
4. **PersistentCacheManager**: Persistent storage implementation
5. **CacheInterceptor**: Dio interceptor for automatic caching
6. **CacheKeyGenerator**: Generates consistent cache keys

## Troubleshooting

### Cache Not Working

1. Ensure caching is enabled: `NetworkLocator.init(enableCache: true)`
2. Check if `CacheOptions` is provided in the request
3. Verify the cache duration is not expired

### Memory Usage Concerns

The cache uses persistent storage (disk) rather than memory, so it won't affect app memory usage significantly.

### Cache Invalidation Issues

```dart
// Debug cache keys
final keys = await NetworkLocator.getCacheManager()?.getAllKeys();
print('All cache keys: $keys');

// Check specific cache
final exists = await NetworkLocator.getCacheManager()?.exists(specificKey);
print('Cache exists: $exists');
```

## Migration Guide

If you're upgrading from a version without caching:

1. **No Breaking Changes**: All existing code continues to work
2. **Opt-in Caching**: Add `cacheOptions` parameter only where needed
3. **Backward Compatible**: Non-cached requests work exactly as before

```dart
// Before (still works)
final response = await apiClient.get('/users/profile');

// After (with caching)
final response = await apiClient.get(
  '/users/profile',
  cacheOptions: const CacheOptions.withDefault(),
);
```

## Examples

See `example/cache_usage_example.dart` for comprehensive usage examples.