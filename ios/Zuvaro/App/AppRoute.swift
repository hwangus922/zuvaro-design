import Foundation

enum AppTab: Hashable {
    case home, board, me
}

enum AppRoute: Hashable {
    case challenge(Challenge)
    case inProgress(Challenge)
    case submitProof(Challenge)
    case proofUploading(Challenge)
    case proofPending(Challenge)
    case proofApproved(Challenge)
    case proofRejected(Challenge)
    case questChain
    case search
    case submissions
    case chat
    case createDare
    case notifications
    case invite
    case settings
    case editProfile
    case setUsername
    case privacy
    case blockedUsers
    case help
    case adminReview
    case adminSubmission(AdminSubmission)
    case signIn
    case emailAuth
}
