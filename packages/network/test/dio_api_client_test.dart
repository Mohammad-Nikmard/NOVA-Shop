import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network/src/dio_api_client.dart';

import 'dio_api_client_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Dio>()])
void main() {
  late MockDio mockDio;
  late DioApiClient apiClient;

  setUp(() {
    mockDio = MockDio();
    apiClient = DioApiClient(dio: mockDio);
  });

  group('DioApiClient', () {
    test('get method returns NetworkResponse on success', () async {
      when(
        mockDio.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: 'test data',
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final response = await apiClient.get('test_endpoint');

      expect(response.statusCode, 200);
      expect(response.data, 'test data');
    });

    test('post method returns NetworkResponse on success', () async {
      when(
        mockDio.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 'test data',
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final response = await apiClient.post('test_endpoint', {'key': 'value'});

      expect(response.statusCode, 200);
      expect(response.data, 'test data');
    });

    test('put method returns NetworkResponse on success', () async {
      when(
        mockDio.put(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 'test data',
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final response = await apiClient.put('test_endpoint', {'key': 'value'});

      expect(response.statusCode, 200);
      expect(response.data, 'test data');
    });

    test('delete method returns NetworkResponse on success', () async {
      when(
        mockDio.delete(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 'test data',
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final response = await apiClient.delete('test_endpoint', {
        'key': 'value',
      });

      expect(response.statusCode, 200);
      expect(response.data, 'test data');
    });
  });
}
