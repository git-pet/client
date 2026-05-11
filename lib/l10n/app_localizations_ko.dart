// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'GitPet';

  @override
  String get introSkip => '건너뛰기';

  @override
  String get introNext => '다음';

  @override
  String get introStart => '시작하기';

  @override
  String get introPage1Title => 'GitPet에 오신 걸 환영해요!';

  @override
  String get introPage1Description => '커밋할수록 성장하는 나만의 펫을\n키워보세요.';

  @override
  String get introPage2Title => '커밋으로 성장';

  @override
  String get introPage2Description =>
      'Git 활동이 곧 펫의 경험치!\n꾸준한 개발이 펫을 더 강하게 만들어요.';

  @override
  String get introPage3Title => '목표를 달성하세요';

  @override
  String get introPage3Description => '연속 커밋 기록을 세우고\n특별한 보상을 받아보세요.';

  @override
  String get loginTagline => '커밋할수록 자라나는, 나만의 작은 펫';

  @override
  String get loginConnectedBadge => '연결됨';

  @override
  String get loginContinueWithGithub => 'GitHub로 계속하기';

  @override
  String get loginErrorSupabaseUnconfigured =>
      'Supabase 설정이 없어 GitHub 로그인을 시작할 수 없습니다.';

  @override
  String get loginStatusOpeningBrowser => 'GitHub 로그인 페이지를 여는 중입니다.';

  @override
  String get loginStatusCompleteInBrowser => '브라우저에서 GitHub 로그인을 완료하세요.';

  @override
  String loginStatusSignedIn(String login) {
    return 'GitHub 로그인 완료: @$login';
  }

  @override
  String get loginStatusSignedOut => '로그아웃되었습니다.';

  @override
  String get loginErrorGeneric => '로그인에 실패하였습니다';

  @override
  String get homeAppTitle => 'GitPet Home';

  @override
  String get homePetRoomTitle => '나의 펫 룸';

  @override
  String get homeTabActivity => '활동내역';

  @override
  String get homeTabFriends => '친구';

  @override
  String get homeTabExplore => '탐색';

  @override
  String get homeTabShop => '상점';

  @override
  String get homeTabCollapseHint => '탭을 접으려면 이 영역을 누르세요.';

  @override
  String homeTabPlaceholder(String tab) {
    return '$tab 정보가 이 영역에 표시될 예정입니다.';
  }

  @override
  String get homeSettingsTitle => '설정';

  @override
  String get homeSettingsDescription => '계정과 앱 관련 기능을 여기서 관리합니다.';

  @override
  String get homeSettingsPetChange => '펫 변경 (Debug)';

  @override
  String get homeSettingsLanguage => '언어 변경';

  @override
  String get homeSettingsLanguageDescription => '앱에서 사용할 언어를 선택합니다.';

  @override
  String get homeLanguageSelectorTitle => '언어 선택';

  @override
  String get homeLanguageSystem => '시스템 기본값';

  @override
  String get homeSettingsLogout => '로그아웃';

  @override
  String get homeSettingsLogoutDescription => '현재 연결된 GitHub 계정을 해제합니다.';

  @override
  String get homePetSelectorTitle => '펫 선택 (Debug)';

  @override
  String get homeLogoutFailed => '로그아웃에 실패하였습니다.';

  @override
  String get homeSessionExpired => 'GitHub 인증이 만료되어 다시 로그인이 필요합니다.';

  @override
  String get homeActivityUserNotFound => 'GitHub 사용자 정보를 찾을 수 없습니다.';

  @override
  String homeActivityFetchFailed(int status) {
    return 'GitHub 활동을 불러오지 못했습니다. ($status)';
  }

  @override
  String get homeActivityInvalidResponse => 'GitHub 응답 형식이 올바르지 않습니다.';

  @override
  String get homeActivityCollapsedHint => '탭을 확장하면 GitHub 활동을 불러옵니다.';

  @override
  String get homeActivityLoadError => '활동을 불러오지 못했습니다.';

  @override
  String get homeActivityRetry => '다시 시도';

  @override
  String get homeActivityDefaultName => 'GitHub 활동';

  @override
  String homeActivityRecentSubtitle(String login) {
    return '@$login의 최근 공개 활동';
  }

  @override
  String get homeActivityEmpty => '표시할 공개 활동이 아직 없습니다.';

  @override
  String get homeUnknownRepo => '알 수 없는 저장소';

  @override
  String get activityTitlePush => '커밋을 푸시했어요';

  @override
  String get activityTitlePr => 'PR 활동이 있어요';

  @override
  String get activityTitleIssue => '이슈 활동이 있어요';

  @override
  String get activityTitleIssueComment => '이슈 댓글을 남겼어요';

  @override
  String get activityTitlePrReview => 'PR 리뷰를 남겼어요';

  @override
  String get activityTitleWatch => '저장소에 스타를 눌렀어요';

  @override
  String get activityTitleCreate => '브랜치 또는 태그를 생성했어요';

  @override
  String get activityTitleFork => '저장소를 포크했어요';

  @override
  String activityTitleDefault(String type) {
    return '$type 활동';
  }

  @override
  String activityDescPushWithMessage(String repo, int count, String message) {
    return '$repo · $count개 커밋 · $message';
  }

  @override
  String activityDescPushCount(String repo, int count) {
    return '$repo · $count개 커밋 푸시';
  }

  @override
  String activityDescPushFallback(String repo) {
    return '$repo에 커밋을 푸시했습니다.';
  }

  @override
  String activityDescPrWithTitle(String repo, String action, String title) {
    return '$repo · PR $action · $title';
  }

  @override
  String activityDescPrNoTitle(String repo, String action) {
    return '$repo · PR $action';
  }

  @override
  String activityDescIssueWithTitle(String repo, String action, String title) {
    return '$repo · 이슈 $action · $title';
  }

  @override
  String activityDescIssueNoTitle(String repo, String action) {
    return '$repo · 이슈 $action';
  }

  @override
  String activityDescIssueCommentWithTitle(String repo, String title) {
    return '$repo · 댓글 작성 · $title';
  }

  @override
  String activityDescIssueCommentNoTitle(String repo) {
    return '$repo · 댓글 작성';
  }

  @override
  String activityDescPrReview(String repo, String state) {
    return '$repo · 리뷰 $state';
  }

  @override
  String activityDescWatch(String repo) {
    return '$repo · star';
  }

  @override
  String activityDescCreateWithRef(String repo, String refType, String ref) {
    return '$repo · $refType 생성 · $ref';
  }

  @override
  String activityDescCreateNoRef(String repo, String refType) {
    return '$repo · $refType 생성';
  }

  @override
  String activityDescFork(String repo) {
    return '$repo · 포크 생성';
  }

  @override
  String get relativeJustNow => '방금 전';

  @override
  String relativeMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes분 전',
    );
    return '$_temp0';
  }

  @override
  String relativeHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours시간 전',
    );
    return '$_temp0';
  }

  @override
  String relativeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days일 전',
    );
    return '$_temp0';
  }

  @override
  String relativeMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months개월 전',
    );
    return '$_temp0';
  }

  @override
  String relativeYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years년 전',
    );
    return '$_temp0';
  }
}
