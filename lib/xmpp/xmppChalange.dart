

import 'dart:convert';

import 'package:crypto/crypto.dart';

String? clientNonce;

Map<String, String> parseChallenge(String base64Challenge) {
  
  final decoded = utf8.decode(base64.decode(base64Challenge));
  
  final parts = decoded.split(',');
  
  return {
    'nonce': parts[0].substring(2),
    'salt': parts[1].substring(2),
    'iteration_count': parts[2].substring(2),
  };
}

String createClientProof({
  required String username,
  required String password,
  required String clientNonce,
  required String serverNonce,
  required String saltBase64,
  required String iterationCount,
}) {
  // Decode parameters
  final salt = base64.decode(saltBase64);
  final iterations = int.parse(iterationCount);
  
  // 1. Compute SaltedPassword
  final saltedPassword = hi(utf8.encode(password),salt,iterations,);
  
  // 2. Compute ClientKey
  final clientKey = hmacSha1(saltedPassword, utf8.encode('Client Key'));
  
  // 3. Compute StoredKey
  final storedKey = sha1.convert(clientKey).bytes;
  
  // 4. Create AuthMessage
  final authMessage = utf8.encode(
    'n=${escapeUsername(username)},r=$clientNonce,'
    'r=${clientNonce + serverNonce},s=$saltBase64,'
    'i=$iterationCount,'
    'c=biws,r=${clientNonce + serverNonce}'
  );
  
  // 5. Compute ClientSignature
  final clientSignature = hmacSha1(storedKey, authMessage);
  
  // 6. Compute ClientProof
  final clientProof = xor(clientKey, clientSignature);
  
  // 7. Create client-final-message
  return 'c=biws,r=${clientNonce + serverNonce},p=${base64.encode(clientProof)}';
}

List<int> hi(List<int> password, List<int> salt, int iterations) {
  var u = hmacSha1(password, salt + [0, 0, 0, 1]);
  var result = List<int>.from(u);
  
  for (var i = 1; i < iterations; i++) {
    u = hmacSha1(password, u);
    for (var j = 0; j < u.length; j++) {
      result[j] ^= u[j];
    }
  }
  
  return result;
}

List<int> hmacSha1(List<int> key, List<int> data) {
  final hmac = Hmac(sha1, key);
  return hmac.convert(data).bytes;
}

List<int> xor(List<int> a, List<int> b) {
  return List.generate(a.length, (i) => a[i] ^ b[i]);
}

String createChallengeResponse(String clientFinalMessage) {
  final base64Response = base64.encode(utf8.encode(clientFinalMessage));
  return '''
<response xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
  $base64Response
</response>
''';
}

String escapeUsername(String username) {
  return username.replaceAll('=', '=3D').replaceAll(',', '=2C');
}