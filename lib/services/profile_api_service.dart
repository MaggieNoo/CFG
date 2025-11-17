import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ProfileApiService {
  // Update Profile API
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String firstName,
    required String middleName,
    required String lastName,
    required String gender,
    required String birthday,
    required String address,
    required String company,
    required String email,
    required String phone,
    String? phone2,
    required String username,
    required String password,
    String? profileBase64,
  }) async {
    try {
      final url = '${AppConstants.baseUrl}app.account.php';
      print('Update Profile URL: $url');
      print('User ID: $userId');
      print('Birthday: $birthday');

      // Calculate request size
      final profileSize =
          (profileBase64?.length ?? 0) * 0.75 / 1024; // Approximate KB
      print(
          'Profile image size in request: ${profileSize.toStringAsFixed(2)} KB');
      print(
          'Sending profile image: ${(profileBase64?.isNotEmpty ?? false) ? "YES" : "NO"}');

      final response = await http.post(
        Uri.parse(url),
        body: {
          'ftr': '100-3',
          'token': AppConstants.apiToken,
          'key': '',
          'sid': userId,
          'fn': firstName,
          'mn': middleName,
          'ln': lastName,
          'gender': gender,
          'bday': birthday, // Format: MM-DD-YYYY
          'address': address,
          'company': company,
          'email': email,
          'phone': phone,
          'phone2': phone2 ?? '',
          'un': username,
          'pw': password,
          'profile': profileBase64 ?? '',
        },
      );

      print('Update Profile Response Status: ${response.statusCode}');
      print('Update Profile Response Body: ${response.body}');
      print('Response length: ${response.body.length} characters');

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (!response.body.trim().startsWith('{') &&
            !response.body.trim().startsWith('[')) {
          print('ERROR: Server returned non-JSON response');
          print('Full response:');
          print(response.body);
          return {
            'success': false,
            'message': 'Server error. Please check the logs for details.',
          };
        }

        try {
          final Map<String, dynamic> data = json.decode(response.body);

          print('=== Backend Response ===');
          print('count: ${data['count']}');
          print('result: ${data['result']}');
          print('has data field: ${data.containsKey('data')}');
          print('data is null: ${data['data'] == null}');
          if (data['data'] != null) {
            final dataStr = data['data'].toString();
            final previewLen = dataStr.length > 100 ? 100 : dataStr.length;
            print('data value: ${dataStr.substring(0, previewLen)}...');
          }

          if (data['count'] == '1') {
            // Parse updated user data if provided
            Map<String, dynamic>? userData;
            if (data['data'] != null && data['data'].toString().isNotEmpty) {
              try {
                print('Attempting to parse user data...');
                userData = json.decode(data['data']);
                print('✓ User data parsed successfully');
                print(
                    'Profile field exists: ${userData?.containsKey('profile')}');
                print(
                    'Profile field length: ${userData?['profile']?.toString().length ?? 0}');
              } catch (e) {
                print('✗ Error parsing user data: $e');
                print('data content: ${data['data']}');
              }
            } else {
              print('⚠ data field is null or empty');
            }

            return {
              'success': true,
              'message': 'Profile updated successfully',
              'userData': userData, // Return updated user data
            };
          } else {
            return {
              'success': false,
              'message': data['result'] ?? 'Update failed',
            };
          }
        } on FormatException catch (e) {
          print('JSON Parse Error: $e');
          print('Response Body: ${response.body}');
          return {
            'success': false,
            'message':
                'Server error: Invalid response format. Check server logs.',
          };
        }
      } else if (response.statusCode == 413) {
        return {
          'success': false,
          'message':
              'Image too large. Please try a smaller photo or contact support.',
        };
      } else {
        return {
          'success': false,
          'message':
              'Server error (${response.statusCode}). Please try again later.',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Change Password API
  static Future<Map<String, dynamic>> changePassword({
    required String userToken,
    required String username,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final url = '${AppConstants.baseUrl}app.account.php';
      print('Change Password URL: $url');
      print('User Token: $userToken');
      print('Username: $username');

      // Send the encrypted token (from user.token field)
      final response = await http.post(
        Uri.parse(url),
        body: {
          'ftr': '110-3',
          'token': AppConstants.apiToken,
          'key': 'x',
          'itoken': userToken, // Using encrypted token from user.token
          'un': username,
          'pw': newPassword,
        },
      );

      print('Change Password Response Status: ${response.statusCode}');
      print('Change Password Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['count'] == '1' && data['code'] == '0') {
          return {
            'success': true,
            'message': data['msg'] ?? 'Password changed successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['result'] ?? 'Password change failed',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Server error (${response.statusCode}). Please try again later.',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }
}
