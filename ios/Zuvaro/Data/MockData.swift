import Foundation

enum MockData {
    static let sponsors: [Sponsor] = [
        Sponsor(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!,
            name: "Pulse Energy",
            tagline: "Fuel missions outside",
            logoEmoji: "⚡",
            websiteURL: "https://example.com/pulse"
        ),
        Sponsor(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000102")!,
            name: "Swift Sip Coffee",
            tagline: "Show up caffeinated",
            logoEmoji: "☕",
            websiteURL: "https://example.com/swiftsip"
        ),
        Sponsor(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000103")!,
            name: "Trailhead Co.",
            tagline: "Gear for real-world dares",
            logoEmoji: "🥾",
            websiteURL: "https://example.com/trailhead"
        ),
    ]

    static let prizePool = PrizePool(
        id: UUID(),
        regionId: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
        title: "West weekly pool",
        totalCents: 750_00,
        currency: "usd",
        periodEnd: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    )

    static let regions: [Region] = [
        Region(id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!, code: "us-west", name: "West", kind: .usRegion, sortOrder: 5),
        Region(id: UUID(uuidString: "00000000-0000-0000-0000-000000000021")!, code: "country-ca", name: "Canada", kind: .country, sortOrder: 10)
    ]

    static let challenges: [Challenge] = [
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            time: "5 min", text: "Give a genuine compliment", points: 15,
            hook: "Spread good vibes", minutes: 5,
            rules: "Compliment someone in person—a friend or a stranger. Submit a photo or short caption as proof."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            time: "15 min", text: "Reach out to an old friend", points: 20,
            hook: "Reconnect", minutes: 15,
            rules: "Send a friendly text or voice note to someone you have not talked to in a while. Screenshot the message as proof."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            time: "20 min", text: "Take a 20-minute walk", points: 25,
            hook: "Get moving", minutes: 20,
            rules: "Walk outside for at least 20 minutes. A photo of your route, step count, or a scenic shot counts as proof.",
            sponsor: sponsors[2]
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            time: "30 min", text: "Try a food you have never had", points: 30,
            hook: "Adventure bite", minutes: 30,
            rules: "Order or cook something new to you. Submit a photo with your dish.",
            sponsor: sponsors[1]
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            time: "1 min", text: "Tell a clean joke to two people", points: nil,
            hook: "Comedy hour", minutes: 1,
            rules: "Share a family-friendly joke with at least two people. Bonus points if they laugh."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
            time: "10 min", text: "Let the crew pick your story post", points: 35,
            hook: "No takesies backsies", minutes: 10,
            rules: "Your group picks one photo from your camera roll. You post it to your story with zero context. Screenshot the story as proof."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
            time: "5 min", text: "Send your crush a bold text", points: 25,
            hook: "Shoot your shot", minutes: 5,
            rules: "Send one flirty or chaotic text to someone you are into. Keep it consensual and playful. Screenshot proof."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
            time: "3 min", text: "Hit the worm in public", points: 30,
            hook: "Main character energy", minutes: 3,
            rules: "Do the worm somewhere public. Video or photo proof required.",
            sponsor: sponsors[0]
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!,
            time: "24 hrs", text: "Rock a crew-picked outfit", points: 45,
            hook: "Fashion victim arc", minutes: 1440,
            rules: "Let your crew vote on tomorrow's fit. Wear it for at least 4 hours in public."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
            time: "15 min", text: "Voice note your worst hot take", points: 20,
            hook: "Unfiltered", minutes: 15,
            rules: "Record a 30-second voice note confessing your most unhinged (but harmless) opinion."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
            time: "20 min", text: "Eat the cursed combo", points: 40,
            hook: "Chef's kiss???", minutes: 20,
            rules: "Your crew picks two foods that should not go together. You eat a bite on camera."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
            time: "10 min", text: "FaceTime lyrics only", points: 20,
            hook: "Broadway who?", minutes: 10,
            rules: "Call a friend and speak only in song lyrics for at least 2 minutes."
        ),
        Challenge(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!,
            time: "1 hr", text: "Phone on the table, unlocked", points: 50,
            hook: "Trust fall but digital", minutes: 60,
            rules: "At dinner with friends, leave your phone face-up and unlocked on the table for 1 hour. They can look but not post or message."
        ),
    ]

    static let submissions: [Submission] = [
        Submission(
            id: UUID(), challengeId: challenges[0].id,
            dareTitle: "Give a genuine compliment", status: .pending, points: 15,
            createdAt: Date().addingTimeInterval(-120)
        ),
        Submission(
            id: UUID(), challengeId: challenges[1].id,
            dareTitle: "Reach out to an old friend", status: .approved, points: 20,
            createdAt: Date().addingTimeInterval(-86400)
        ),
        Submission(
            id: UUID(), challengeId: challenges[2].id,
            dareTitle: "Take a 20-minute walk", status: .rejected, points: 25,
            createdAt: Date().addingTimeInterval(-259200)
        ),
    ]

    static let friendsBoard: [LeaderboardEntry] = {
        let pool = prizePool
        let rows = [
            LeaderboardEntry(id: UUID(), rank: 1, name: "John Winner", handle: "@IloveMyGTA6too", points: 981, emoji: "👑"),
            LeaderboardEntry(id: UUID(), rank: 2, name: "John Second", handle: "@IloveMyGTA6137", points: 972, emoji: "🦊"),
            LeaderboardEntry(id: UUID(), rank: 3, name: "John Third", handle: "@IhateMyElCinco2", points: 970, emoji: "🐺"),
            LeaderboardEntry(id: UUID(), rank: 4, name: "John Fourth", handle: "@IloveMyElCinco5", points: 890, emoji: "🐸"),
            LeaderboardEntry(id: UUID(), rank: 5, name: "John Fifth", handle: "@IhateMyAirfrier6", points: 690, emoji: "🦝"),
            LeaderboardEntry(id: UUID(), rank: 67, name: "John Airfrier", handle: "@IloveMyAirfrier48", points: 70, emoji: "🍳", isMe: true),
        ]
        return rows.map { $0.withPayout(from: pool) }
    }()

    static let chatMessages: [ChatMessage] = [
        ChatMessage(id: UUID(), userId: UUID(), author: "Maya", emoji: "🦊", text: "who's doing the compliment dare tonight??", time: "2:14 PM"),
        ChatMessage(id: UUID(), userId: UUID(), author: "Alex", emoji: "🐺", text: "Give a genuine compliment", time: "2:18 PM", isDare: true, dareChallengeId: challenges[0].id, darePoints: 15),
        ChatMessage(id: UUID(), userId: UUID(), author: "You", emoji: "👑", text: "already submitted proof lol", time: "2:22 PM", isMe: true),
        ChatMessage(id: UUID(), userId: UUID(), author: "Jordan", emoji: "🦝", text: "nice one on the walk dare!", time: "2:31 PM"),
        ChatMessage(id: UUID(), userId: UUID(), author: "Alex", emoji: "🐺", text: "Reach out to an old friend", time: "2:45 PM", isDare: true, dareChallengeId: challenges[1].id, darePoints: 20),
    ]

    static let contactFriends: [ContactFriendMatch] = [
        ContactFriendMatch(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000201")!,
            displayName: "Maya Chen",
            handle: "@mayachen",
            avatarEmoji: "🦊"
        ),
        ContactFriendMatch(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000202")!,
            displayName: "Alex Rivera",
            handle: "@alexr",
            avatarEmoji: "🐺"
        )
    ]

    static let notifications: [AppNotification] = [
        AppNotification(id: UUID(), title: "Proof approved", body: "+15pts for \"Give a genuine compliment\"", time: "2m ago", unread: true, kind: .proof),
        AppNotification(id: UUID(), title: "New dare in Chaos Crew", body: "Alex posted \"Reach out to an old friend\" · +20pts", time: "18m ago", unread: true, kind: .dare),
        AppNotification(id: UUID(), title: "You dropped a rank", body: "Jordan passed you on the Friends board", time: "1h ago", unread: true, kind: .board),
        AppNotification(id: UUID(), title: "Maya joined Zuvaro", body: "Invite accepted — say hi in the group chat", time: "Yesterday", unread: false, kind: .friend),
    ]
}
