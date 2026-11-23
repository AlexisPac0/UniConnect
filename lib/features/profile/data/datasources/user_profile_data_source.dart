import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniconnect/features/profile/data/models/user_profile_model.dart';

/// Low-level access to the user profiles. Implementations may throw.
abstract interface class UserProfileDataSource {
  /// Returns the profile of [userId], or `null` when it does not exist.
  Future<UserProfileModel?> getUserProfile(String userId);
}

/// [UserProfileDataSource] reading the Firestore document `users/{userId}`.
///
/// Throws a `FirebaseException` on backend errors and the errors of
/// [UserProfileModel.fromMap] when the document is invalid.
class FirestoreUserProfileDataSource implements UserProfileDataSource {
  const FirestoreUserProfileDataSource(this._firestore);

  static const String collection = 'users';

  final FirebaseFirestore _firestore;

  @override
  Future<UserProfileModel?> getUserProfile(String userId) async {
    final snapshot = await _firestore.collection(collection).doc(userId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return UserProfileModel.fromMap(snapshot.id, data);
  }
}
