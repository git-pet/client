// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GitPet';

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Next';

  @override
  String get introStart => 'Get started';

  @override
  String get introPage1Title => 'Welcome to GitPet!';

  @override
  String get introPage1Description =>
      'Raise your very own pet\nthat grows with every commit.';

  @override
  String get introPage2Title => 'Grow through commits';

  @override
  String get introPage2Description =>
      'Your Git activity is your pet\'s XP.\nKeep coding to make it stronger.';

  @override
  String get introPage3Title => 'Reach your goals';

  @override
  String get introPage3Description =>
      'Build commit streaks and\nearn special rewards.';

  @override
  String get loginTagline => 'A tiny pet that grows with your commits';

  @override
  String get loginConnectedBadge => 'Connected';

  @override
  String get loginContinueWithGithub => 'Continue with GitHub';

  @override
  String get loginErrorSupabaseUnconfigured =>
      'Supabase is not configured, so GitHub sign-in can\'t start.';

  @override
  String get loginStatusOpeningBrowser => 'Opening the GitHub sign-in page.';

  @override
  String get loginStatusCompleteInBrowser =>
      'Finish signing in with GitHub in your browser.';

  @override
  String loginStatusSignedIn(String login) {
    return 'Signed in to GitHub as @$login';
  }

  @override
  String get loginStatusSignedOut => 'You have been signed out.';

  @override
  String get loginErrorGeneric => 'Sign-in failed';

  @override
  String get homeAppTitle => 'GitPet Home';

  @override
  String get homePetRoomTitle => 'My pet room';

  @override
  String get homeTabActivity => 'Activity';

  @override
  String get homeTabFriends => 'Friends';

  @override
  String get homeTabExplore => 'Explore';

  @override
  String get homeTabShop => 'Shop';

  @override
  String get homeTabCollapseHint => 'Tap this area to collapse the panel.';

  @override
  String homeTabPlaceholder(String tab) {
    return '$tab content will appear here.';
  }

  @override
  String get homeSettingsTitle => 'Settings';

  @override
  String get homeSettingsDescription =>
      'Manage your account and app features here.';

  @override
  String get homeSettingsPetChange => 'Change pet (Debug)';

  @override
  String get homeSettingsLanguage => 'Language';

  @override
  String get homeSettingsLanguageDescription => 'Choose your app language.';

  @override
  String get homeLanguageSelectorTitle => 'Select language';

  @override
  String get homeLanguageSystem => 'System default';

  @override
  String get homeSettingsLogout => 'Sign out';

  @override
  String get homeSettingsLogoutDescription =>
      'Disconnect the linked GitHub account.';

  @override
  String get homePetSelectorTitle => 'Choose a pet (Debug)';

  @override
  String get homeLogoutFailed => 'Sign-out failed.';

  @override
  String get homeSessionExpired =>
      'Your GitHub session has expired. Please sign in again.';

  @override
  String get homeActivityUserNotFound => 'GitHub user info could not be found.';

  @override
  String homeActivityFetchFailed(int status) {
    return 'Failed to load GitHub activity. ($status)';
  }

  @override
  String get homeActivityInvalidResponse =>
      'GitHub returned an invalid response.';

  @override
  String get homeActivityCollapsedHint =>
      'Expand the tab to load GitHub activity.';

  @override
  String get homeActivityLoadError => 'Could not load activity.';

  @override
  String get homeActivityRetry => 'Try again';

  @override
  String get homeActivityDefaultName => 'GitHub activity';

  @override
  String homeActivityRecentSubtitle(String login) {
    return 'Recent public activity of @$login';
  }

  @override
  String get homeActivityEmpty => 'No public activity to show yet.';

  @override
  String get homeUnknownRepo => 'Unknown repository';

  @override
  String get activityTitleCommit => 'Pushed commits';

  @override
  String get activityTitlePullRequest => 'Pull request activity';

  @override
  String get activityTitleIssue => 'Issue activity';

  @override
  String get activityTitleCodeReview => 'Reviewed a pull request';

  @override
  String get activityTitleStar => 'Starred a repository';

  @override
  String get activityTitleFork => 'Forked a repository';

  @override
  String get activityTitleRelease => 'Published a release';

  @override
  String activityTitleDefault(String type) {
    return '$type activity';
  }

  @override
  String activityDescCommitWithMessage(String repo, int count, String message) {
    return '$repo · $count commits · $message';
  }

  @override
  String activityDescCommitCount(String repo, int count) {
    return '$repo · $count commits pushed';
  }

  @override
  String activityDescCommitFallback(String repo) {
    return 'Pushed commits to $repo.';
  }

  @override
  String activityDescPullRequestWithTitle(
    String repo,
    String action,
    String title,
  ) {
    return '$repo · PR $action · $title';
  }

  @override
  String activityDescPullRequestNoTitle(String repo, String action) {
    return '$repo · PR $action';
  }

  @override
  String activityDescIssueWithTitle(String repo, String action, String title) {
    return '$repo · issue $action · $title';
  }

  @override
  String activityDescIssueNoTitle(String repo, String action) {
    return '$repo · issue $action';
  }

  @override
  String activityDescCodeReview(String repo, String state) {
    return '$repo · review $state';
  }

  @override
  String activityDescStar(String repo) {
    return '$repo · star';
  }

  @override
  String activityDescFork(String repo) {
    return '$repo · fork created';
  }

  @override
  String activityDescReleaseWithTag(String repo, String tag) {
    return '$repo · release $tag';
  }

  @override
  String activityDescReleaseNoTag(String repo) {
    return '$repo · release published';
  }

  @override
  String get relativeJustNow => 'Just now';

  @override
  String relativeMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String relativeHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String relativeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String relativeMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String relativeYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }
}
