import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(MD3ColorScheme.primary)

                Text(titleText)
                    .font(.title)
                    .foregroundColor(MD3ColorScheme.onSurface)

                // MD3 Fields
                switch viewModel.authState {
                case .enteringPhone:
                    MD3FloatingTextField(title: "Phone Number", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                case .enteringCode:
                    MD3FloatingTextField(title: "Code", text: $viewModel.authCode)
                        .keyboardType(.numberPad)
                case .enteringPassword:
                    MD3FloatingTextField(title: "Password", text: $viewModel.twoFAPassword, isSecure: true)
                case .authenticated:
                    Text("Authenticated!")
                        .foregroundColor(MD3ColorScheme.primary)
                }

                // Submit Button
                if viewModel.authState != .authenticated {
                    Button(action: submitAction) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(MD3ColorScheme.onPrimary)
                        } else {
                            Text(buttonText)
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(MD3ColorScheme.primary)
                    .foregroundColor(MD3ColorScheme.onPrimary)
                    .clipShape(Capsule())
                    .disabled(viewModel.isLoading)
                }

                Spacer()
            }
            .padding(24)
            .background(MD3ColorScheme.surface.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var titleText: String {
        switch viewModel.authState {
        case .enteringPhone: return "Your Phone"
        case .enteringCode: return "Enter Code"
        case .enteringPassword: return "2-Step Verification"
        case .authenticated: return "Welcome"
        }
    }

    private var buttonText: String {
        switch viewModel.authState {
        case .enteringPhone: return "Next"
        case .enteringCode: return "Next"
        case .enteringPassword: return "Submit"
        case .authenticated: return ""
        }
    }

    private func submitAction() {
        switch viewModel.authState {
        case .enteringPhone: viewModel.submitPhone()
        case .enteringCode: viewModel.submitCode()
        case .enteringPassword: viewModel.submitPassword()
        case .authenticated: break
        }
    }
}
