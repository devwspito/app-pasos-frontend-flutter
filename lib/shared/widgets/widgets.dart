/// Reusable widget library following Material Design 3 guidelines.
///
/// This library provides a collection of pre-built, customizable widgets
/// that ensure consistency across the application.
///
/// ## Widgets included:
///
/// ### Buttons
/// - [AppButton] - Primary, secondary, and text button variants
///
/// ### Inputs
/// - [AppTextField] - Text input with validation support
///
/// ### Cards
/// - [AppCard] - Card with elevation variants
/// - [AppOutlinedCard] - Card with outlined border
///
/// ### Loading States
/// - [LoadingIndicator] - Circular progress indicator
/// - [LoadingOverlay] - Full-screen loading overlay
/// - [ProgressLoadingIndicator] - Determinate progress indicator
///
/// ### Error States
/// - [AppErrorWidget] - Error display with retry option
/// - [CriticalErrorWidget] - Prominent error for critical issues
/// - [InlineError] - Compact inline error message
///
/// ### Empty States
/// - [EmptyStateWidget] - Generic empty state display
/// - [NoSearchResultsWidget] - Empty state for search
/// - [NoConnectionWidget] - Empty state for connection issues
/// - [EmptyListWidget] - Empty state for lists
/// - [ComingSoonWidget] - Placeholder for upcoming features
library widgets;

export 'app_button.dart';
export 'app_card.dart';
export 'app_text_field.dart';
export 'empty_state_widget.dart';
export 'error_widget.dart';
export 'loading_indicator.dart';
