class AppConstants {
  // App Info
  static const String appName = 'Yolog';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'user_settings';

  // Error Messages
  static const String networkError = '네트워크 연결을 확인해주세요.';
  static const String unknownError = '알 수 없는 오류가 발생했습니다.';
  static const String invalidEmail = '올바른 이메일 형식이 아닙니다.';
  static const String invalidPassword = '비밀번호는 6자 이상이어야 합니다.';
  static const String passwordMismatch = '비밀번호가 일치하지 않습니다.';
  static const String emailAlreadyInUse = '이미 사용 중인 이메일입니다.';
  static const String userNotFound = '등록되지 않은 이메일입니다.';
  static const String wrongPassword = '잘못된 비밀번호입니다.';

  // Success Messages
  static const String signupSuccess = '회원가입이 완료되었습니다.';
  static const String loginSuccess = '로그인되었습니다.';
  static const String logoutSuccess = '로그아웃되었습니다.';
  static const String passwordResetEmailSent = '비밀번호 재설정 이메일을 보냈습니다.';

  // Validation Messages
  static const String requiredField = '필수 입력 항목입니다.';
  static const String minLength = '최소 {n}자 이상이어야 합니다.';
  static const String maxLength = '최대 {n}자까지 입력 가능합니다.';

  // Button Text
  static const String confirm = '확인';
  static const String cancel = '취소';
  static const String save = '저장';
  static const String edit = '수정';
  static const String delete = '삭제';
  static const String next = '다음';
  static const String back = '이전';

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String googleIconPath = 'assets/icons/google.png';

  // API Endpoints
  static const String baseUrl = 'https://api.yolog.com'; // 예시 URL
  static const String apiVersion = '/v1';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
