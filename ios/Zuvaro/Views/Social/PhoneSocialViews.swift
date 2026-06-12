import SwiftUI

struct PhoneSettingsView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var phoneInput = ""
    @State private var otpCode = ""
    @State private var step: Step = .phone
    @State private var discoverable = false
    @State private var smsEnabled = false
    @State private var isLoading = false

    private enum Step { case phone, verify, linked }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: "Phone & SMS", onBack: { appModel.pop() })

                Text("Add your number to get text updates and let friends find you on Zuvaro. Your full contact list is never uploaded — we only match phone numbers you choose to share.")
                    .font(.system(size: 13))
                    .foregroundStyle(ZuvaroTheme.textMute)

                if let error = appModel.phoneError {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundStyle(ZuvaroTheme.orange)
                }

                if appModel.currentProfile?.hasVerifiedPhone == true {
                    linkedPhoneSection
                } else {
                    verificationSection
                }

                if AppConfig.usesMockBackend {
                    Text("Demo mode: use verification code 123456.")
                        .font(.system(size: 11))
                        .foregroundStyle(ZuvaroTheme.textDim)
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
        .onAppear { syncFromProfile() }
    }

    @ViewBuilder
    private var verificationSection: some View {
        switch step {
        case .phone:
            TextField("Phone number", text: $phoneInput)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .padding(14)
                .background(ZuvaroTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            PrimaryButton(title: isLoading ? "Sending..." : "Send verification code", enabled: !isLoading && !phoneInput.trimmingCharacters(in: .whitespaces).isEmpty) {
                sendCode()
            }
        case .verify:
            Text("Enter the 6-digit code we texted to your phone.")
                .font(.system(size: 13))
                .foregroundStyle(ZuvaroTheme.textMute)
            TextField("123456", text: $otpCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .padding(14)
                .background(ZuvaroTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            PrimaryButton(title: isLoading ? "Verifying..." : "Verify phone", enabled: !isLoading && otpCode.count >= 6) {
                verify()
            }
            SecondaryTextButton(title: "Use a different number") { step = .phone; otpCode = "" }
        case .linked:
            EmptyView()
        }
    }

    @ViewBuilder
    private var linkedPhoneSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Verified number")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ZuvaroTheme.textMute)
                Text(appModel.currentProfile?.phoneDisplayLabel ?? "Linked")
                    .font(.system(size: 16, weight: .semibold))
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(ZuvaroTheme.orange)
        }
        .padding(14)
        .background(ZuvaroTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))

        Toggle(isOn: $discoverable) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Let friends find me by phone")
                Text("People who have your number in their contacts can see you on Zuvaro.")
                    .font(.system(size: 12))
                    .foregroundStyle(ZuvaroTheme.textMute)
            }
        }
        .padding(14)
        .background(ZuvaroTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onChange(of: discoverable) { _, _ in savePreferences() }

        Toggle(isOn: $smsEnabled) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Text me Zuvaro updates")
                Text("Proof results, crew activity, and prize pool reminders. Message and data rates may apply.")
                    .font(.system(size: 12))
                    .foregroundStyle(ZuvaroTheme.textMute)
            }
        }
        .padding(14)
        .background(ZuvaroTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onChange(of: smsEnabled) { _, _ in savePreferences() }

        Button("Remove phone number") {
            Task { await appModel.removePhoneNumber() }
        }
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(ZuvaroTheme.orange)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func syncFromProfile() {
        discoverable = appModel.currentProfile?.phoneDiscoverable ?? false
        smsEnabled = appModel.currentProfile?.smsNotificationsEnabled ?? false
        if appModel.currentProfile?.hasVerifiedPhone == true {
            step = .linked
        }
    }

    private func sendCode() {
        isLoading = true
        Task {
            let ok = await appModel.requestPhoneVerification(phone: phoneInput)
            await MainActor.run {
                isLoading = false
                if ok { step = .verify }
            }
        }
    }

    private func verify() {
        isLoading = true
        Task {
            let ok = await appModel.verifyPhoneCode(otpCode)
            await MainActor.run {
                isLoading = false
                if ok { syncFromProfile() }
            }
        }
    }

    private func savePreferences() {
        Task { await appModel.updatePhonePreferences(discoverable: discoverable, smsEnabled: smsEnabled) }
    }
}

struct FindFriendsView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var isSearching = false
    @State private var accessDenied = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: "Find friends", onBack: { appModel.pop() })

                Text("See which contacts already use Zuvaro. We normalize phone numbers on your device and only send those numbers to match — your contact names and full address book are never uploaded.")
                    .font(.system(size: 13))
                    .foregroundStyle(ZuvaroTheme.textMute)

                if let error = appModel.phoneError {
                    Text(error).font(.system(size: 12)).foregroundStyle(ZuvaroTheme.orange)
                }

                if accessDenied {
                    Text("Contacts access is off. Enable it in Settings → Zuvaro → Contacts to find friends.")
                        .font(.system(size: 13))
                        .foregroundStyle(ZuvaroTheme.textMute)
                        .padding(14)
                        .background(ZuvaroTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                PrimaryButton(title: isSearching ? "Searching..." : "Find friends from contacts", enabled: !isSearching) {
                    findFriends()
                }

                if !appModel.contactMatches.isEmpty {
                    Text("ON ZUVARO")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.textMute)
                        .padding(.top, 8)

                    ForEach(appModel.contactMatches) { friend in
                        HStack(spacing: 12) {
                            AvatarView(emoji: friend.avatarEmoji, size: 44)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(friend.displayName)
                                    .font(.system(size: 15, weight: .semibold))
                                Text(friend.handle)
                                    .font(.system(size: 12))
                                    .foregroundStyle(ZuvaroTheme.textMute)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(ZuvaroTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                } else if !isSearching && !accessDenied {
                    Text("No matches yet. Friends need a verified, discoverable phone number on Zuvaro.")
                        .font(.system(size: 13))
                        .foregroundStyle(ZuvaroTheme.textMute)
                }

                SecondaryTextButton(title: "Manage phone & SMS settings") {
                    appModel.navigate(to: .phoneSettings)
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }

    private func findFriends() {
        isSearching = true
        appModel.phoneError = nil
        Task {
            let granted = await ContactsService.requestAccess()
            guard granted else {
                await MainActor.run {
                    accessDenied = true
                    isSearching = false
                }
                return
            }
            await appModel.findFriendsFromContacts()
            await MainActor.run { isSearching = false }
        }
    }
}
