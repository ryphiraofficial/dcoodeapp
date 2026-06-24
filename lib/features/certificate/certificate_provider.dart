import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'certificate_model.dart';
import 'package:dio/dio.dart';

class CertificateProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  bool _isLoading = false;
  CertificateData? _certificateData;

  bool get isLoading => _isLoading;
  CertificateData? get certificateData => _certificateData;

  Future<bool> generateCertificate(String studentId, {String? description}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post(
        '/certificate/generate/$studentId',
        data: description != null ? {'description': description} : null,
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      debugPrint('Generate Certificate Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
      Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
    Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

  Future<void> fetchCertificateData(String studentId) async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      debugPrint('[DEBUG] Fetching certificate for student: $studentId');
      
      // Use a timeout to avoid infinite loading
      final response = await _apiClient.dio.get(
        '/certificate/$studentId',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      debugPrint('[DEBUG] API Response Code: ${response.statusCode}');
      debugPrint('[DEBUG] API Response Body: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          _certificateData = CertificateData.fromJson(response.data['certificate']);
          debugPrint('[DEBUG] Certificate data parsed successfully: ${_certificateData?.studentName}');
        } else {
          debugPrint('[DEBUG] API returned success=false: ${response.data['message']}');
          Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
        Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
    } catch (e) {
      debugPrint('[DEBUG] Fetch Certificate Data Error: $e');
      if (e is DioException) {
        debugPrint('[DEBUG] Dio Error Type: ${e.type}');
        debugPrint('[DEBUG] Dio Error Message: ${e.message}');
        debugPrint('[DEBUG] Dio Error Response: ${e.response?.data}');
        Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
    } finally {
      _isLoading = false;
      notifyListeners();
      Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
    Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

  Future<List<CertificateData>> fetchBatchCertificates(String batchId) async {
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint('[DEBUG] Fetching certificates for batch: $batchId');
      final response = await _apiClient.dio.get('/certificate/batch/$batchId');
      debugPrint('[DEBUG] Batch API Response: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        // Try different common paths for the certificates list
        final List? certificates = response.data['certificates'] ?? 
                                   response.data['data']?['certificates'] ?? 
                                   response.data['data'];
        
        if (certificates != null && certificates is List) {
          debugPrint('[DEBUG] Found ${certificates.length} certificates in batch');
          return certificates.map((json) => CertificateData.fromJson(json)).toList();
        } else {
          debugPrint('[DEBUG] No certificates list found in batch response');
          Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
        Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
    } catch (e) {
      debugPrint('[DEBUG] Fetch Batch Certificates Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
    return [];
    Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

  Future<bool> bulkGenerateCertificates(String batchId, {String? description}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post(
        '/certificate/generate/batch/$batchId',
        data: description != null ? {'description': description} : null,
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      debugPrint('Bulk Generate Certificates Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
      Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
    Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
  Future<void> fetchMyCertificate() async {
    _isLoading = true;
    _certificateData = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/certificate/me');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _certificateData = CertificateData.fromJson(response.data['certificate']);
      }
    } catch (e) {
      debugPrint('Fetch My Certificate Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
