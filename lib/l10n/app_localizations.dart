import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GitPet'**
  String get appTitle;

  /// No description provided for @introSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get introNext;

  /// No description provided for @introStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get introStart;

  /// No description provided for @introPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to GitPet!'**
  String get introPage1Title;

  /// No description provided for @introPage1Description.
  ///
  /// In en, this message translates to:
  /// **'Raise your very own pet\nthat grows with every commit.'**
  String get introPage1Description;

  /// No description provided for @introPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Grow through commits'**
  String get introPage2Title;

  /// No description provided for @introPage2Description.
  ///
  /// In en, this message translates to:
  /// **'Your Git activity is your pet\'s XP.\nKeep coding to make it stronger.'**
  String get introPage2Description;

  /// No description provided for @introPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Reach your goals'**
  String get introPage3Title;

  /// No description provided for @introPage3Description.
  ///
  /// In en, this message translates to:
  /// **'Build commit streaks and\nearn special rewards.'**
  String get introPage3Description;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'A tiny pet that grows with your commits'**
  String get loginTagline;

  /// No description provided for @loginConnectedBadge.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get loginConnectedBadge;

  /// No description provided for @loginContinueWithGithub.
  ///
  /// In en, this message translates to:
  /// **'Continue with GitHub'**
  String get loginContinueWithGithub;

  /// No description provided for @loginErrorSupabaseUnconfigured.
  ///
  /// In en, this message translates to:
  /// **'Supabase is not configured, so GitHub sign-in can\'t start.'**
  String get loginErrorSupabaseUnconfigured;

  /// No description provided for @loginStatusOpeningBrowser.
  ///
  /// In en, this message translates to:
  /// **'Opening the GitHub sign-in page.'**
  String get loginStatusOpeningBrowser;

  /// No description provided for @loginStatusCompleteInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Finish signing in with GitHub in your browser.'**
  String get loginStatusCompleteInBrowser;

  /// No description provided for @loginStatusSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in to GitHub as @{login}'**
  String loginStatusSignedIn(String login);

  /// No description provided for @loginStatusSignedOut.
  ///
  /// In en, this message translates to:
  /// **'You have been signed out.'**
  String get loginStatusSignedOut;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed'**
  String get loginErrorGeneric;

  /// No description provided for @homeAppTitle.
  ///
  /// In en, this message translates to:
  /// **'GitPet Home'**
  String get homeAppTitle;

  /// No description provided for @homePetRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'My pet room'**
  String get homePetRoomTitle;

  /// No description provided for @homeTabActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get homeTabActivity;

  /// No description provided for @homeTabFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get homeTabFriends;

  /// No description provided for @homeTabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homeTabExplore;

  /// No description provided for @homeTabShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get homeTabShop;

  /// No description provided for @homeTabCollapseHint.
  ///
  /// In en, this message translates to:
  /// **'Tap this area to collapse the panel.'**
  String get homeTabCollapseHint;

  /// No description provided for @homeTabPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'{tab} content will appear here.'**
  String homeTabPlaceholder(String tab);

  /// No description provided for @homeSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsTitle;

  /// No description provided for @homeSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your account and app features here.'**
  String get homeSettingsDescription;

  /// No description provided for @homeSettingsPetChange.
  ///
  /// In en, this message translates to:
  /// **'Change pet (Debug)'**
  String get homeSettingsPetChange;

  /// No description provided for @homeSettingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get homeSettingsLanguage;

  /// No description provided for @homeSettingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your app language.'**
  String get homeSettingsLanguageDescription;

  /// No description provided for @homeLanguageSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get homeLanguageSelectorTitle;

  /// No description provided for @homeLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get homeLanguageSystem;

  /// No description provided for @homeSettingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get homeSettingsLogout;

  /// No description provided for @homeSettingsLogoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Disconnect the linked GitHub account.'**
  String get homeSettingsLogoutDescription;

  /// No description provided for @homePetSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a pet (Debug)'**
  String get homePetSelectorTitle;

  /// No description provided for @homeLogoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-out failed.'**
  String get homeLogoutFailed;

  /// No description provided for @homeSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your GitHub session has expired. Please sign in again.'**
  String get homeSessionExpired;

  /// No description provided for @homeActivityUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'GitHub user info could not be found.'**
  String get homeActivityUserNotFound;

  /// No description provided for @homeActivityFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load GitHub activity. ({status})'**
  String homeActivityFetchFailed(int status);

  /// No description provided for @homeActivityInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'GitHub returned an invalid response.'**
  String get homeActivityInvalidResponse;

  /// No description provided for @homeActivityCollapsedHint.
  ///
  /// In en, this message translates to:
  /// **'Expand the tab to load GitHub activity.'**
  String get homeActivityCollapsedHint;

  /// No description provided for @homeActivityLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load activity.'**
  String get homeActivityLoadError;

  /// No description provided for @homeActivityRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get homeActivityRetry;

  /// No description provided for @homeActivityDefaultName.
  ///
  /// In en, this message translates to:
  /// **'GitHub activity'**
  String get homeActivityDefaultName;

  /// No description provided for @homeActivityRecentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent public activity of @{login}'**
  String homeActivityRecentSubtitle(String login);

  /// No description provided for @homeActivityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No public activity to show yet.'**
  String get homeActivityEmpty;

  /// No description provided for @homeUnknownRepo.
  ///
  /// In en, this message translates to:
  /// **'Unknown repository'**
  String get homeUnknownRepo;

  /// No description provided for @activityTitlePush.
  ///
  /// In en, this message translates to:
  /// **'Pushed commits'**
  String get activityTitlePush;

  /// No description provided for @activityTitlePr.
  ///
  /// In en, this message translates to:
  /// **'Pull request activity'**
  String get activityTitlePr;

  /// No description provided for @activityTitleIssue.
  ///
  /// In en, this message translates to:
  /// **'Issue activity'**
  String get activityTitleIssue;

  /// No description provided for @activityTitleIssueComment.
  ///
  /// In en, this message translates to:
  /// **'Left an issue comment'**
  String get activityTitleIssueComment;

  /// No description provided for @activityTitlePrReview.
  ///
  /// In en, this message translates to:
  /// **'Reviewed a pull request'**
  String get activityTitlePrReview;

  /// No description provided for @activityTitleWatch.
  ///
  /// In en, this message translates to:
  /// **'Starred a repository'**
  String get activityTitleWatch;

  /// No description provided for @activityTitleCreate.
  ///
  /// In en, this message translates to:
  /// **'Created a branch or tag'**
  String get activityTitleCreate;

  /// No description provided for @activityTitleFork.
  ///
  /// In en, this message translates to:
  /// **'Forked a repository'**
  String get activityTitleFork;

  /// No description provided for @activityTitleDefault.
  ///
  /// In en, this message translates to:
  /// **'{type} activity'**
  String activityTitleDefault(String type);

  /// No description provided for @activityDescPushWithMessage.
  ///
  /// In en, this message translates to:
  /// **'{repo} · {count} commits · {message}'**
  String activityDescPushWithMessage(String repo, int count, String message);

  /// No description provided for @activityDescPushCount.
  ///
  /// In en, this message translates to:
  /// **'{repo} · {count} commits pushed'**
  String activityDescPushCount(String repo, int count);

  /// No description provided for @activityDescPushFallback.
  ///
  /// In en, this message translates to:
  /// **'Pushed commits to {repo}.'**
  String activityDescPushFallback(String repo);

  /// No description provided for @activityDescPrWithTitle.
  ///
  /// In en, this message translates to:
  /// **'{repo} · PR {action} · {title}'**
  String activityDescPrWithTitle(String repo, String action, String title);

  /// No description provided for @activityDescPrNoTitle.
  ///
  /// In en, this message translates to:
  /// **'{repo} · PR {action}'**
  String activityDescPrNoTitle(String repo, String action);

  /// No description provided for @activityDescIssueWithTitle.
  ///
  /// In en, this message translates to:
  /// **'{repo} · issue {action} · {title}'**
  String activityDescIssueWithTitle(String repo, String action, String title);

  /// No description provided for @activityDescIssueNoTitle.
  ///
  /// In en, this message translates to:
  /// **'{repo} · issue {action}'**
  String activityDescIssueNoTitle(String repo, String action);

  /// No description provided for @activityDescIssueCommentWithTitle.
  ///
  /// In en, this message translates to:
  /// **'{repo} · comment · {title}'**
  String activityDescIssueCommentWithTitle(String repo, String title);

  /// No description provided for @activityDescIssueCommentNoTitle.
  ///
  /// In en, this message translates to:
  /// **'{repo} · comment'**
  String activityDescIssueCommentNoTitle(String repo);

  /// No description provided for @activityDescPrReview.
  ///
  /// In en, this message translates to:
  /// **'{repo} · review {state}'**
  String activityDescPrReview(String repo, String state);

  /// No description provided for @activityDescWatch.
  ///
  /// In en, this message translates to:
  /// **'{repo} · star'**
  String activityDescWatch(String repo);

  /// No description provided for @activityDescCreateWithRef.
  ///
  /// In en, this message translates to:
  /// **'{repo} · {refType} created · {ref}'**
  String activityDescCreateWithRef(String repo, String refType, String ref);

  /// No description provided for @activityDescCreateNoRef.
  ///
  /// In en, this message translates to:
  /// **'{repo} · {refType} created'**
  String activityDescCreateNoRef(String repo, String refType);

  /// No description provided for @activityDescFork.
  ///
  /// In en, this message translates to:
  /// **'{repo} · fork created'**
  String activityDescFork(String repo);

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get relativeJustNow;

  /// No description provided for @relativeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute ago} other{{minutes} minutes ago}}'**
  String relativeMinutes(int minutes);

  /// No description provided for @relativeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hour ago} other{{hours} hours ago}}'**
  String relativeHours(int hours);

  /// No description provided for @relativeDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day ago} other{{days} days ago}}'**
  String relativeDays(int days);

  /// No description provided for @relativeMonths.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, =1{1 month ago} other{{months} months ago}}'**
  String relativeMonths(int months);

  /// No description provided for @relativeYears.
  ///
  /// In en, this message translates to:
  /// **'{years, plural, =1{1 year ago} other{{years} years ago}}'**
  String relativeYears(int years);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
