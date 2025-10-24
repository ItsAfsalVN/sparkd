abstract class AuthRemoteDataSource {
  Future<String> requestOtp(String phoneNumber);
}

class AuthRemoteDataSourceImplementation extends AuthRemoteDataSource {
  @override
  Future<String> requestOtp(String phoneNumber) {
    throw UnimplementedError();
  }
}
