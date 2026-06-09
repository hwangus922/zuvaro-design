import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Group {
            if !appModel.isAuthenticated || appModel.showOnboarding {
                OnboardingFlowView()
            } else if appModel.needsRegionSetup {
                RegionOnboardingView()
            } else if appModel.needsUsernameSetup {
                UsernameOnboardingView()
            } else {
                MainTabView()
            }
        }
        .preferredColorScheme(.light)
        .task { await appModel.bootstrap() }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack(path: $appModel.path) {
            ZStack(alignment: .bottom) {
                Group {
                    switch appModel.selectedTab {
                    case .home: HomeView()
                    case .board: LeaderboardView()
                    case .me: ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                ZuvaroTabBar(selection: $appModel.selectedTab)
            }
            .background(ZuvaroTheme.screenBg)
            .navigationBarHidden(true)
            .navigationDestination(for: AppRoute.self) { route in
                routeView(for: route)
            }
        }
    }

    @ViewBuilder
    private func routeView(for route: AppRoute) -> some View {
        switch route {
        case .challenge(let c): ChallengeDetailView(challenge: c)
        case .inProgress(let c): DareInProgressView(challenge: c)
        case .submitProof(let c): SubmitProofView(challenge: c)
        case .proofUploading(let c): ProofUploadingView(challenge: c)
        case .proofPending(let c): ProofPendingView(challenge: c)
        case .proofApproved(let c): ProofApprovedView(challenge: c)
        case .proofRejected(let c): ProofRejectedView(challenge: c)
        case .questChain: QuestChainView()
        case .search: SearchView()
        case .submissions: MySubmissionsView()
        case .chat: GroupChatView()
        case .createDare: CreateDareView()
        case .notifications: NotificationsView()
        case .invite: InviteFriendsView()
        case .settings: SettingsView()
        case .editProfile: EditProfileView()
        case .setUsername: SetUsernameView()
        case .privacy: PrivacyView()
        case .blockedUsers: BlockedUsersView()
        case .help: HelpSupportView()
        case .adminReview: AdminReviewView()
        case .adminSubmission(let submission): AdminSubmissionDetailView(submission: submission)
        case .signIn:
            SignInView(
                onBack: { appModel.pop() },
                onEmailSignIn: { appModel.navigate(to: .emailAuth) },
                onSignUp: { appModel.pop(); appModel.showOnboarding = true }
            )
        case .emailAuth:
            EmailAuthView(
                isSignUp: false,
                onBack: { appModel.pop() },
                onToggleMode: { appModel.navigate(to: .emailAuth) }
            )
        }
    }
}
