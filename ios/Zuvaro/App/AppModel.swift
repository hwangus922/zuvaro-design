import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var showOnboarding = true
    @Published var selectedTab: AppTab = .home
    @Published var path = NavigationPath()
    @Published var questDone = 1
    let questTotal = 5
    @Published var totalPoints = 70

    func completeOnboarding() {
        showOnboarding = false
    }

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func openChallenge(_ challenge: Challenge) {
        navigate(to: .challenge(challenge))
    }

    func approveProof(for challenge: Challenge) {
        questDone = min(questTotal, questDone + 1)
        if let pts = challenge.points { totalPoints += pts }
        navigate(to: .proofApproved(challenge))
    }

    func rejectProof(for challenge: Challenge) {
        navigate(to: .proofRejected(challenge))
    }
}
