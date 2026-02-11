import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class ScramClient {
  final String username;
  final String password;
  final String mechanism; // 'SCRAM-SHA-1', 'SCRAM-SHA-256', etc
  final String _gs2Header = 'n,,'; // GS2 header for XMPP
  
  String _clientNonce = '';
  String _serverNonce = '';
  String _salt = '';
  int _iterationCount = 0;
  String _authMessage = '';

  ScramClient(this.username, this.password, {this.mechanism = 'SCRAM-SHA-1'});

  String get initialMessage {
    _clientNonce = _generateNonce();
    return base64.encode(utf8.encode('${_gs2Header}n=${_escape(username)},r=$_clientNonce'));
  }

  String processChallenge(String base64Challenge) {
    final challenge = utf8.decode(base64.decode(base64Challenge));
    final params = _parseChallenge(challenge);
    
    _serverNonce = params['r']!;
    _salt = params['s']!;
    _iterationCount = int.parse(params['i']!);
    
    // Generate client proof
    final saltedPassword = _hi(
      utf8.encode(_normalize(password)),
      base64.decode(_salt),
      _iterationCount,
    );
    
    final clientKey = _hmac(saltedPassword, 'Client Key');
    final storedKey = _hash(clientKey);
    final clientFirstMessageBare = 'n=${_escape(username)},r=$_clientNonce';
    final serverFirstMessage = challenge;
    final clientFinalMessageWithoutProof = 'c=${base64.encode(utf8.encode(_gs2Header))},r=$_serverNonce';
    
    _authMessage = '$clientFirstMessageBare,$serverFirstMessage,$clientFinalMessageWithoutProof';
    
    final clientSignature = _hmac(storedKey, _authMessage);
    final clientProof = _xor(clientKey, clientSignature);
    
    return base64.encode(utf8.encode('$clientFinalMessageWithoutProof,p=${base64.encode(clientProof)}'));
  }

  // Helper methods
  String _generateNonce() {
    final random = Random.secure();
    final nonce = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(nonce);
  }

  String _escape(String value) {
    return value.replaceAll('=', '=3D').replaceAll(',', '=2C');
  }

  Map<String, String> _parseChallenge(String challenge) {
    final params = <String, String>{};
    for (final part in challenge.split(',')) {
      final eq = part.indexOf('=');
      if (eq > 0) {
        params[part.substring(0, eq)] = part.substring(eq + 1);
      }
    }
    return params;
  }

  List<int> _hi(List<int> password, List<int> salt, int iterations) {
    final hmac = Hmac(sha1, password); // Use sha256 for SCRAM-SHA-256
    var u = hmac.convert(salt + [0, 0, 0, 1]).bytes;
    var result = List<int>.from(u);
    
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < u.length; j++) {
        result[j] ^= u[j];
      }
    }
    
    return result;
  }

  List<int> _hmac(List<int> key, String message) {
    final hmac = Hmac(sha1, key); // Use sha256 for SCRAM-SHA-256
    return hmac.convert(utf8.encode(message)).bytes;
  }

  List<int> _hash(List<int> data) {
    return sha1.convert(data).bytes; // Use sha256 for SCRAM-SHA-256
  }

  List<int> _xor(List<int> a, List<int> b) {
    assert(a.length == b.length);
    return List<int>.generate(a.length, (i) => a[i] ^ b[i]);
  }

  String _normalize(String password) {
    // Normalize UTF-8 according to SASLprep (simplified)
    return password;
  }
}