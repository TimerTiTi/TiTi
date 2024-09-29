//
//  SignupSigninVC.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/09/27.
//  Copyright © 2023 FDEE. All rights reserved.
//

import UIKit
import Combine
import Moya
import MessageUI

class SignupSigninVC: WhiteNavigationVC {
    private var viewModel: SignupSigninVM
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: CustomView
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    private var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = TiTiImage.signinLogo
        return imageView
    }()
    private var logoTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = Fonts.HGGGothicssiP80g(size: 15)
        label.text = "TimerTiTi"
        return label
    }()
    private let nicknameTextField = SigninInputTextfield(type: .nickname)
    private let emailTextField = SigninInputTextfield(type: .email)
    private let passwordTextField = SigninInputTextfield(type: .password)
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(self.viewModel.isSignin ? Localized.string(.TiTiLab_Button_SignIn) : Localized.string(.TiTiLab_Button_SignUpTitle), for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        button.isUserInteractionEnabled = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: SigninInputTextfield.height)
        ])
        return button
    }()
    private lazy var textFieldsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        return stackView
    }()
    private lazy var optionsBottomView: UIView = {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            backgroundView.heightAnchor.constraint(equalToConstant: SigninInputTextfield.height)
        ])
        
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.addSubview(line)
        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: 1),
            line.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        ])
        
        let labelBackground = UIView()
        labelBackground.translatesAutoresizingMaskIntoConstraints = false
        labelBackground.backgroundColor = Colors.signinBackground
        backgroundView.addSubview(labelBackground)
        
        let orLabel = UILabel()
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        orLabel.text = Localized.string(.SignIn_Text_OR)
        orLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        orLabel.font = Typographys.uifont(.semibold_4, size: 13)
        backgroundView.addSubview(orLabel)
        NSLayoutConstraint.activate([
            orLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            orLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            labelBackground.centerXAnchor.constraint(equalTo: orLabel.centerXAnchor),
            labelBackground.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            labelBackground.widthAnchor.constraint(equalTo: orLabel.widthAnchor, multiplier: 1, constant: 16),
            labelBackground.heightAnchor.constraint(equalTo: orLabel.heightAnchor, multiplier: 1),
            line.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor)
        ])
        
        return backgroundView
    }()
    private lazy var findNicknameButton: UIButton = {
        let button = UIButton(type: .system)
        let title = Localized.string(.SignIn_Button_FindNickname)
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font,
                                      value: Typographys.uifont(.semibold_4, size: 13)!,
                                      range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.black.withAlphaComponent(0.5),
                                      range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: title.count))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(attributedString, for: .normal)
        button.backgroundColor = .clear
        
        return button
    }()
    private lazy var findPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let title = Localized.string(.SignIn_Button_FindPassword)
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font,
                                      value: Typographys.uifont(.semibold_4, size: 13)!,
                                      range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.black.withAlphaComponent(0.5),
                                      range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: title.count))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(attributedString, for: .normal)
        button.backgroundColor = .clear
        
        return button
    }()
    private lazy var contactButton: UIButton = {
        let button = UIButton(type: .system)
        let title = Localized.string(.SignIn_Button_Contect)
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font,
                                      value: Typographys.uifont(.semibold_4, size: 13)!,
                                      range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.black.withAlphaComponent(0.5),
                                      range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: title.count))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(attributedString, for: .normal)
        button.backgroundColor = .clear
        
        return button
    }()
    private lazy var buttonDevider1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "|"
        label.textColor = .black.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.font = Fonts.HGGGothicssiP60g(size: 13)
        return label
    }()
    private lazy var buttonDevider2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "|"
        label.textColor = .black.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.font = Fonts.HGGGothicssiP60g(size: 13)
        return label
    }()
    private lazy var signinOptionsButtonsStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    private var textFieldOrigin: CGPoint = .zero
    // MARK: constraint
    private var contentViewWidth: NSLayoutConstraint?
    
    init(viewModel: SignupSigninVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.configureTextFields()
        self.configureNotifications()
        self.configureUI()
        self.configureActions()
        self.bindAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "TestServer"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.adjustUI(size: self.view.bounds.size)
    }
}

extension SignupSigninVC {
    private func configureTextFields() {
        self.nicknameTextField.textField.delegate = self
        self.emailTextField.textField.delegate = self
        self.passwordTextField.textField.delegate = self
        
        self.passwordTextField.textField.isSecureTextEntry = true
        self.emailTextField.textField.keyboardType = .emailAddress
    }
    
    private func configureNotifications() {
        // keyboardWillShow observer 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func configureUI(width: CGFloat = 300) {
        self.addDismissingKeyboard()
        self.view.backgroundColor = Colors.signinBackground
        
        self.view.addSubview(self.contentView)
        NSLayoutConstraint.activate([
            self.contentView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.contentView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        self.contentViewWidth = self.contentView.widthAnchor.constraint(equalToConstant: width)
        self.contentViewWidth?.isActive = true
        
        self.contentView.addSubview(self.logoImage)
        NSLayoutConstraint.activate([
            self.logoImage.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.logoImage.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ])
        
        self.contentView.addSubview(self.logoTitle)
        NSLayoutConstraint.activate([
            self.logoTitle.topAnchor.constraint(equalTo: self.logoImage.bottomAnchor, constant: 8),
            self.logoTitle.centerXAnchor.constraint(equalTo: self.logoImage.centerXAnchor)
        ])
        
        self.contentView.addSubview(self.textFieldsStackView)
        NSLayoutConstraint.activate([
            self.textFieldsStackView.topAnchor.constraint(equalTo: self.logoTitle.bottomAnchor, constant: 68),
            self.textFieldsStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.textFieldsStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        ])
        
        self.textFieldsStackView.addArrangedSubview(self.nicknameTextField)
        self.textFieldsStackView.addArrangedSubview(self.emailTextField)
        self.textFieldsStackView.addArrangedSubview(self.passwordTextField)
        self.textFieldsStackView.addArrangedSubview(self.actionButton)
        self.textFieldsStackView.addArrangedSubview(self.optionsBottomView)
        
        self.optionsBottomView.addSubview(self.signinOptionsButtonsStackView)
        NSLayoutConstraint.activate([
            self.signinOptionsButtonsStackView.leadingAnchor.constraint(equalTo: self.optionsBottomView.leadingAnchor),
            self.signinOptionsButtonsStackView.trailingAnchor.constraint(equalTo: self.optionsBottomView.trailingAnchor),
            self.signinOptionsButtonsStackView.bottomAnchor.constraint(equalTo: self.optionsBottomView.bottomAnchor)
        ])
        
        self.signinOptionsButtonsStackView.addArrangedSubview(self.findNicknameButton)
        self.signinOptionsButtonsStackView.addArrangedSubview(self.buttonDevider1)
        self.signinOptionsButtonsStackView.addArrangedSubview(self.findPasswordButton)
        self.signinOptionsButtonsStackView.addArrangedSubview(self.buttonDevider2)
        self.signinOptionsButtonsStackView.addArrangedSubview(self.contactButton)
        
        if self.viewModel.isSignin {
            self.emailTextField.isHidden = true
            self.optionsBottomView.isHidden = false
            NSLayoutConstraint.activate([
                self.textFieldsStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
            ])
        } else {
            self.emailTextField.isHidden = false
            self.optionsBottomView.isHidden = true
            NSLayoutConstraint.activate([
                self.textFieldsStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
            ])
        }
    }
    
    private func adjustUI(size: CGSize) {
        switch size.deviceDetailType {
        case .iPhoneMini:
            self.contentViewWidth?.constant = 300
        case .iPhonePro, .iPhoneMax:
            self.contentViewWidth?.constant = size.minLength - 96
        default:
            self.contentViewWidth?.constant = 400
        }
    }
    
    private func configureActions() {
        // MARK: Signup & Signin Action
        self.actionButton.addAction(UIAction(handler: { [weak self] _ in
            guard let username = self?.nicknameTextField.textField.text,
                  let password = self?.passwordTextField.textField.text else { return }
            
            if self?.viewModel.isSignin == true {
                self?.viewModel.signin(request: TestUserSigninRequest(username: username, password: password))
            } else {
                guard let email = self?.emailTextField.textField.text else { return }
                self?.viewModel.signup(request: TestUserSignupRequest(username: username, email: email, password: password))
            }
        }), for: .touchUpInside)
        
        self.findNicknameButton.addAction(UIAction(handler: { [weak self] _ in
            self?.sendMail(text: Localized.string(.EmailMessage_Text_FindNickname))
        }), for: .touchUpInside)
        
        self.findPasswordButton.addAction(UIAction(handler: { [weak self] _ in
            let vc = ResetPasswordVC()
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
        }), for: .touchUpInside)
        
        self.contactButton.addAction(UIAction(handler: { [weak self] _ in
            self?.sendMail(text: Localized.string(.EmailMessage_Text_Message))
        }), for: .touchUpInside)
    }
}

// MARK: - Email

extension SignupSigninVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    private func sendMail(text: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["contact.timertiti@gmail.com"])
            mail.setMessageBody("<p>\(self.transToHTML(text: text))</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            let sendMailErrorAlert = UIAlertController(title: Localized.string(.EmailMessage_Error_CantSendEmailTitle), message: Localized.string(.EmailMessage_Error_CantSendEmailDesc), preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: Localized.string(.Common_Text_OK), style: .default)
            sendMailErrorAlert.addAction(confirmAction)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }
    
    private func transToHTML(text: String) -> String {
        var htmlBody: String = text
        if htmlBody.contains("\n") {
            htmlBody = htmlBody.replacingOccurrences(of: "\n", with: "</p><p>")
        }
        return htmlBody
    }
}

extension SignupSigninVC {
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardRectangle = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // keyboard 높이에 따라 bounds.origin 값 조정
            print(keyboardRectangle.height)
            let keyboardY = self.view.bounds.height - keyboardRectangle.height
            let textFieldOrigin = self.textFieldOrigin
            let targetY = textFieldOrigin.y + SigninInputTextfield.height + 16
            
            if keyboardY <= targetY {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut, .overrideInheritedCurve]) { [weak self] in
                    self?.view.bounds.origin.y = targetY - keyboardY
                }
            }
        }
    }
}

extension SignupSigninVC {
    private func bindAll() {
        self.bindLoadingText()
        self.bindAlert()
        self.bindPostable()
        self.bindSigninSuccess()
    }
    
    private func bindLoadingText() {
        self.viewModel.$loadingText
            .receive(on: DispatchQueue.main)
            .sink { text in
                guard let text = text else {
                    LoadingIndicator.hideLoading()
                    return
                }
                LoadingIndicator.showLoading(text: text)
            }
            .store(in: &self.cancellables)
    }
    
    private func bindPostable() {
        self.viewModel.$postable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] postable in
                if postable {
                    self?.actionButton.backgroundColor = .tintColor
                    self?.actionButton.setTitleColor(.white, for: .normal)
                    self?.actionButton.isUserInteractionEnabled = true
                } else {
                    self?.actionButton.isUserInteractionEnabled = false
                    self?.actionButton.backgroundColor = .white
                    self?.actionButton.setTitleColor(.gray, for: .normal)
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func bindAlert() {
        self.viewModel.$alert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alertInfo in
                guard let alertInfo = alertInfo else { return }
                self?.showAlertWithOK(title: alertInfo.title, text: alertInfo.text)
            }
            .store(in: &self.cancellables)
    }
    
    private func bindSigninSuccess() {
        self.viewModel.$signinSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signinSuccess in
                guard signinSuccess else { return }
                
                let title: String = self?.viewModel.isSignin == true ? Localized.string(.SignIn_Popup_SigninSuccess) : Localized.string(.SignUp_Popup_SignupSuccess)
                self?.showAlertWithOKAfterHandler(title: title, text: "") { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &self.cancellables)
    }
}

extension SignupSigninVC: UITextFieldDelegate {
    /// return 키 설정
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nicknameTextField.textField {
            if self.viewModel.isSignin {
                self.passwordTextField.textField.becomeFirstResponder()
            } else {
                self.emailTextField.textField.becomeFirstResponder()
            }
        } else if textField == self.emailTextField.textField {
            self.passwordTextField.textField.becomeFirstResponder()
        } else if textField == self.passwordTextField.textField {
            self.dismissKeyboard()
        }
        
        return true
    }
    
    /// textField 활성화시 origin 값 설정 -> 이후 keyboardWillShow 메소드 내에서 bounds.origin 값 조정
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textFieldOrigin = self.textFieldOrigin(textField)
    }
    
    /// textField 비활성화시 bounds.origin 리셋
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut,.overrideInheritedCurve]) { [weak self] in
            self?.view.bounds.origin.y = 0
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let nickname = self.nicknameTextField.textField.text
        let email = self.emailTextField.textField.text
        let password = self.passwordTextField.textField.text
        self.viewModel.check(nickname: nickname, email: email, password: password)
    }
    
    private func textFieldOrigin(_ textField: UITextField) -> CGPoint {
        var textFieldOrigin: CGPoint = .zero
        if textField == self.nicknameTextField.textField {
            textFieldOrigin = self.nicknameTextField.origin
        } else if textField == self.emailTextField.textField {
            textFieldOrigin = self.emailTextField.origin
        } else {
            textFieldOrigin = self.passwordTextField.origin
        }
        
        let stackViewOrigin = self.textFieldsStackView.frame.origin
        let contentViewOrigin = self.contentView.frame.origin
        
        return textFieldOrigin + stackViewOrigin + contentViewOrigin
    }
}

// MARK: Preview

#if DEBUG
import SwiftUI

#Preview {
    UIViewControllerPreview {
        // TODO: DI 수정
        let api = TTProvider<AuthAPI>(session: Session(interceptor: NetworkInterceptor.shared))
        let repository = AuthRepository(api: api)
        let signupUseCase = SignupUseCase(repository: repository)
        let signinUseCase = SigninUseCase(repository: repository)
        
        let viewModel = SignupSigninVM(signupUseCase: signupUseCase, signinUseCase: signinUseCase, isSignin: false)
        return SignupSigninVC(viewModel: viewModel)
    }
}

#endif
