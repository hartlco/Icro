import SwiftUI

struct LoginView: View {
    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    LoginHeader()
                    LoginSignInCard(viewModel: viewModel)
                    Text("LOGIN_POWERED_BY_MICROBLOG")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 460)
                .padding(.horizontal, 24)
                .padding(.top, 48)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
            .background {
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.14), Color(uiColor: .systemBackground)],
                    startPoint: .topLeading,
                    endPoint: .center
                )
                .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ITEMNAVIGATOR_MOREALERT_CANCELACTION") {
                        viewModel.didDismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct LoginHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(Color.accentColor.gradient, in: RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.accentColor.opacity(0.25), radius: 18, y: 8)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("LOGIN_WELCOME_TITLE")
                    .font(.largeTitle.bold())
                Text("LOGIN_WELCOME_SUBTITLE")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

private struct LoginSignInCard: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("LOGIN_METHOD", selection: $viewModel.loginType) {
                Text("LOGIN_EMAIL_OPTION").tag(LoginViewModel.LoginType.mail)
                Text("LOGIN_TOKEN_OPTION").tag(LoginViewModel.LoginType.token)
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 10) {
                Group {
                    if viewModel.loginType == .mail {
                        Text("LOGIN_EMAIL_LABEL")
                    } else {
                        Text("LOGIN_TOKEN_LABEL")
                    }
                }
                .font(.subheadline.weight(.semibold))

                Group {
                    if viewModel.loginType == .mail {
                        TextField("LOGIN_EMAIL_FIELD", text: $viewModel.loginString)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                    } else {
                        SecureField("LOGIN_TOKEN_FIELD", text: $viewModel.loginString)
                            .textContentType(.password)
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .onSubmit { viewModel.login() }
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(.background, in: RoundedRectangle(cornerRadius: 14))

                Group {
                    if viewModel.loginType == .mail {
                        Text("LOGIN_EMAIL_HINT")
                    } else {
                        Text("LOGIN_TOKEN_HINT")
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            if let message = viewModel.infoMessage {
                Label(message, systemImage: viewModel.loginType == .mail ? "envelope.badge" : "info.circle")
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                viewModel.login()
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    }
                    Text(viewModel.buttonString)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.buttonActivated)
        }
        .padding(24)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28))
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel())
    }
}
#endif
