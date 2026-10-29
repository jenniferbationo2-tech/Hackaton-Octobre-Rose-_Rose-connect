import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assistant/assistant_screen.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/auth_models.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/community/community_screen.dart';
import '../../features/education/education_detail_screen.dart';
import '../../features/education/education_list_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/legal/legal_content.dart';
import '../../features/legal/legal_screen.dart';
import '../../features/orientation/orientation_intro_screen.dart';
import '../../features/orientation/orientation_questions_screen.dart';
import '../../features/orientation/orientation_result_screen.dart';
import '../../features/quiz/quiz_intro_screen.dart';
import '../../features/quiz/quiz_play_screen.dart';
import '../../features/quiz/quiz_result_screen.dart';
import '../widgets/main_shell.dart';

abstract final class AppRoutes {
  static const home = '/home';
  static const education = '/home/education';
  static String educationDetail(String id) => '/home/education/$id';
  static const assistant = '/assistant';
  static const orientation = '/orientation';
  static const orientationQuestions = '/orientation/questions';
  static const orientationResult = '/orientation/result';
  static const quiz = '/quiz';
  static const quizPlay = '/quiz/play';
  static const quizResult = '/quiz/result';
  static const community = '/community';
  // Hors barre de navigation : à ouvrir avec context.push.
  static const privacy = '/privacy';
  static const terms = '/terms';
  static const profile = '/profile';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
}

/// Pages accessibles avant d'avoir passé l'écran de bienvenue.
const _onboardingRoutes = {
  AppRoutes.welcome,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.privacy,
  AppRoutes.terms,
};

final routerProvider = Provider<GoRouter>((ref) {
  // Réévalue les redirections à chaque changement de session.
  final authChanges = ValueNotifier(0);
  ref.listen(authControllerProvider, (_, _) => authChanges.value++);
  ref.onDispose(authChanges.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final location = state.matchedLocation;
      if (status == AuthStatus.onboarding) {
        return _onboardingRoutes.contains(location) ? null : AppRoutes.welcome;
      }
      if (location == AppRoutes.welcome) return AppRoutes.home;
      if (status == AuthStatus.signedIn &&
          (location == AppRoutes.login || location == AppRoutes.register)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'education',
                  builder: (context, state) => const EducationListScreen(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => EducationDetailScreen(
                        id: state.pathParameters['id']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.assistant,
              builder: (context, state) => const AssistantScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.orientation,
              builder: (context, state) => const OrientationIntroScreen(),
              routes: [
                GoRoute(
                  path: 'questions',
                  builder: (context, state) =>
                      const OrientationQuestionsScreen(),
                ),
                GoRoute(
                  path: 'result',
                  builder: (context, state) => const OrientationResultScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.quiz,
              builder: (context, state) => const QuizIntroScreen(),
              routes: [
                GoRoute(
                  path: 'play',
                  builder: (context, state) => const QuizPlayScreen(),
                ),
                GoRoute(
                  path: 'result',
                  builder: (context, state) => const QuizResultScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.community,
              builder: (context, state) => const CommunityScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) =>
            const LegalScreen(document: privacyPolicy),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) => const LegalScreen(document: termsOfUse),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cette page est introuvable.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text("Retour à l'accueil"),
            ),
          ],
        ),
      ),
    ),
  );
});
