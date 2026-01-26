/// API endpoint constants for all backend communication.
///
/// This class contains all the API paths used for server communication.
/// All paths are relative and should be appended to the base URL.
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  // ==========================================================================
  // Base Paths
  // ==========================================================================

  /// Base path for authentication endpoints
  static const String authBase = '/api/auth';

  /// Base path for user endpoints
  static const String usersBase = '/api/users';

  /// Base path for steps endpoints
  static const String stepsBase = '/api/steps';

  /// Base path for goals endpoints
  static const String goalsBase = '/api/goals';

  /// Base path for sharing endpoints
  static const String sharingBase = '/api/sharing';

  // ==========================================================================
  // Authentication Endpoints
  // ==========================================================================

  /// POST - Register a new user account
  static const String register = '$authBase/register';

  /// POST - Login with credentials
  static const String login = '$authBase/login';

  /// POST - Logout current session
  static const String logout = '$authBase/logout';

  /// POST - Refresh access token
  static const String refresh = '$authBase/refresh';

  // ==========================================================================
  // User Endpoints
  // ==========================================================================

  /// GET - Get current authenticated user
  static const String me = '$usersBase/me';

  /// GET/PUT - User profile operations
  static const String profile = '$usersBase/profile';

  // ==========================================================================
  // Steps Endpoints
  // ==========================================================================

  /// GET - List all steps with pagination
  static const String stepsList = stepsBase;

  /// POST - Create a new step entry
  static const String stepsCreate = stepsBase;

  /// GET - Get daily step summary
  static const String stepsDaily = '$stepsBase/daily';

  /// GET - Get weekly step summary
  static const String stepsWeekly = '$stepsBase/weekly';

  /// Helper to get step by ID
  static String stepsById(String id) => '$stepsBase/$id';

  // ==========================================================================
  // Goals Endpoints
  // ==========================================================================

  /// GET - List all goals
  static const String goalsList = goalsBase;

  /// POST - Create a new goal
  static const String goalsCreate = goalsBase;

  /// POST - Join a shared goal
  static const String goalsJoin = '$goalsBase/join';

  /// POST - Leave a shared goal
  static const String goalsLeave = '$goalsBase/leave';

  /// Helper to get goal by ID
  static String goalsById(String id) => '$goalsBase/$id';

  // ==========================================================================
  // Sharing Endpoints
  // ==========================================================================

  /// GET - List all sharing connections
  static const String sharingList = sharingBase;

  /// POST - Send a sharing request
  static const String sharingRequest = '$sharingBase/request';

  /// POST - Accept a sharing request
  static const String sharingAccept = '$sharingBase/accept';

  /// POST - Reject a sharing request
  static const String sharingReject = '$sharingBase/reject';

  /// Helper to get sharing connection by ID
  static String sharingById(String id) => '$sharingBase/$id';
}
