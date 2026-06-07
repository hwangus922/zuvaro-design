import Foundation

enum MockData {
    static let challenges: [Challenge] = [
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            time: "6 min", text: "Let yo bih go thru yo phone", points: 20,
            hook: "Oh hell naw jigsaw u tweaking bruh", minutes: 6,
            rules: "Hand your phone unlocked to someone in the room for 6 minutes. They can scroll anything except banking apps."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            time: "9 min", text: "Text your ex", points: 10,
            hook: "Yes.", minutes: 9,
            rules: "Send one honest text to your ex. No scheduling a call."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            time: "2 hrs", text: "Run 10 km", points: 50,
            hook: "Burn some calories", minutes: 120,
            rules: "Continuous run or walk. Strava / Apple Health / a sweaty selfie counts as proof."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            time: "5 hrs", text: "Larp having money", points: 60,
            hook: "Larp larp larp sahur", minutes: 300,
            rules: "Post a story flexing obvious fake wealth for at least 5 hours."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            time: "1 min", text: "Make a dumb joke", points: nil,
            hook: "Pure embarrassment", minutes: 1,
            rules: "Tell the joke out loud to at least two people. Groans = success."
        ),
    ]

    static let submissions: [Submission] = [
        Submission(
            id: UUID(), challengeId: challenges[0].id,
            dareTitle: "Let yo bih go thru yo phone", status: .pending, points: 20,
            createdAt: Date().addingTimeInterval(-120)
        ),
        Submission(
            id: UUID(), challengeId: challenges[1].id,
            dareTitle: "Text your ex", status: .approved, points: 10,
            createdAt: Date().addingTimeInterval(-86400)
        ),
        Submission(
            id: UUID(), challengeId: challenges[2].id,
            dareTitle: "Run 10 km", status: .rejected, points: 50,
            createdAt: Date().addingTimeInterval(-259200)
        ),
    ]

    static let friendsBoard: [LeaderboardEntry] = [
        LeaderboardEntry(id: UUID(), rank: 1, name: "John Winner", handle: "@IloveMyGTA6too", points: 981, emoji: "👑"),
        LeaderboardEntry(id: UUID(), rank: 2, name: "John Second", handle: "@IloveMyGTA6137", points: 972, emoji: "🦊"),
        LeaderboardEntry(id: UUID(), rank: 3, name: "John Third", handle: "@IhateMyElCinco2", points: 970, emoji: "🐺"),
        LeaderboardEntry(id: UUID(), rank: 4, name: "John Fourth", handle: "@IloveMyElCinco5", points: 890, emoji: "🐸"),
        LeaderboardEntry(id: UUID(), rank: 5, name: "John Fifth", handle: "@IhateMyAirfrier6", points: 690, emoji: "🦝"),
        LeaderboardEntry(id: UUID(), rank: 67, name: "John Airfrier", handle: "@IloveMyAirfrier48", points: 70, emoji: "🍳", isMe: true),
    ]

    static let chatMessages: [ChatMessage] = [
        ChatMessage(id: UUID(), author: "Maya", emoji: "🦊", text: "who's doing the phone dare tonight??", time: "2:14 PM"),
        ChatMessage(id: UUID(), author: "Alex", emoji: "🐺", text: "Let yo bih go thru yo phone", time: "2:18 PM", isDare: true, dareChallengeId: challenges[0].id, darePoints: 20),
        ChatMessage(id: UUID(), author: "You", emoji: "👑", text: "already submitted proof lol", time: "2:22 PM", isMe: true),
        ChatMessage(id: UUID(), author: "Jordan", emoji: "🦝", text: "LMAO the rejection on mine was brutal", time: "2:31 PM"),
        ChatMessage(id: UUID(), author: "Alex", emoji: "🐺", text: "Text your ex", time: "2:45 PM", isDare: true, dareChallengeId: challenges[1].id, darePoints: 10),
    ]

    static let notifications: [AppNotification] = [
        AppNotification(id: UUID(), title: "Proof approved", body: "+20pts for \"Let yo bih go thru yo phone\"", time: "2m ago", unread: true, kind: .proof),
        AppNotification(id: UUID(), title: "New dare in Chaos Crew", body: "Alex posted \"Text your ex\" · +10pts", time: "18m ago", unread: true, kind: .dare),
        AppNotification(id: UUID(), title: "You dropped a rank", body: "Jordan passed you on the Friends board", time: "1h ago", unread: true, kind: .board),
        AppNotification(id: UUID(), title: "Maya joined Zuvaro", body: "Invite accepted — say hi in the group chat", time: "Yesterday", unread: false, kind: .friend),
    ]
}
