import Foundation

enum AuthState {
    case enteringPhone
    case enteringCode
    case enteringPassword
    case authenticated
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .enteringPhone

    @Published var phoneNumber: String = ""
    @Published var authCode: String = ""
    @Published var twoFAPassword: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func submitPhone() {
        guard !phoneNumber.isEmpty else { return }
        isLoading = true
        // Mock TDLib setAuthenticationPhoneNumber request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.authState = .enteringCode
        }
    }

    func submitCode() {
        guard !authCode.isEmpty else { return }
        isLoading = true
        // Mock TDLib checkAuthenticationCode request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.authState = .enteringPassword
        }
    }

    func submitPassword() {
        guard !twoFAPassword.isEmpty else { return }
        isLoading = true
        // Mock TDLib checkAuthenticationPassword request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.authState = .authenticated
        }
    }
}
