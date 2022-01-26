//
//  UpaxViewController.swift
//  testUpax-David-Guillermo-Lopez-Vazquez
//
//  Created by David Lopez on 1/25/22.
//  Copyright (c) 2022 UPAX. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import FirebaseStorage

protocol SelfieDelegate: AnyObject {
    func update(selfieImage: UIImage)
}

protocol UpaxDisplayLogic: AnyObject {
    func displayGraph(viewModel: UpaxModels.FetchSalinas.ViewModel)
}

class UpaxViewController: UIViewController, UpaxDisplayLogic, EnableFormDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var interactor: UpaxBusinessLogic?
    var router: (NSObjectProtocol & UpaxRoutingLogic & UpaxDataPassing)?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentSendButtonView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    var imagePicker: UIImagePickerController!
    var selfieImage: UIImage? {
        didSet {
            self.enableForm(enable: self.textFieldEmpty)
        }
    }
    weak var selfieDelegate: SelfieDelegate?
    var sectionTitles = ["Nombre", "Selfie"]
    var questions = [[Chart]]()
    var textFieldEmpty = false
    private let storage = Storage.storage().reference()
    
    // MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup Clean Code
    private func setup() {
        let viewController = self
        let interactor = UpaxInteractor()
        let presenter = UpaxPresenter()
        let router = UpaxRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchRequest()
    }
    
    func setupUI() {
        self.setupHideKeyboardOnTap()
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).font = UIFont.boldSystemFont(ofSize: 12)
        contentSendButtonView.addShadow(location: .top, color: .gray, opacity: 0.16, radius: 4)
        sendButton.isEnabled = false
    }
    
    func fetchRequest() {
        let request = UpaxModels.FetchSalinas.Request()
        interactor?.fetchSalinas(request: request)
    }

    // MARK: - Display
    func displayGraph(viewModel: UpaxModels.FetchSalinas.ViewModel) {
        
        // Section Title
        sectionTitles += viewModel.titles
        questions = viewModel.questions
        tableView.reloadData()
    }
    
    func takePhoto() {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selfieImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        self.selfieDelegate?.update(selfieImage: selfieImage)
        self.selfieImage = selfieImage
    }
    
    func enableForm(enable: Bool) {
        self.textFieldEmpty = enable
        sendButton.isEnabled = enable && (self.selfieImage != nil)
    }
    
    // MARK: Acions
    @IBAction func sendButtonAction(_ sender: Any) {
        guard let selfieImage = self.selfieImage else {
            return
        }
        guard let selfieData = selfieImage.pngData() else {
            return
        }
        storage.child("images/selfie.png").putData(selfieData, metadata: nil) { _, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            
            self.storage.child("images/selfie.png").downloadURL { url, error in
                guard let url = url, error == nil else {
                    return
                }
                let urlStr = url.absoluteString
                print("Downloading URL: \(urlStr)")
                
            }
            
        }
    }
}

extension UpaxViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case UpaxEnum.name.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier) as? TextFieldTableViewCell else {
                return UITableViewCell()
            }
            cell.enableFormDelegate = self
            return cell
        case UpaxEnum.selfie.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SelfieTableViewCell.identifier) as? SelfieTableViewCell else {
                return UITableViewCell()
            }
            selfieDelegate = cell
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GraphTableViewCell.identifier) as? GraphTableViewCell else {
                return UITableViewCell()
            }
            let question = questions[indexPath.section - 2]
            let dataPoints = question.map { $0.text }
            let values = question.map { $0.percentage }
            let colors = question.map { $0.color }
            cell.update(dataPoints: dataPoints, values: values, colors: colors)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}

extension UpaxViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == UpaxEnum.selfie.rawValue {
            takePhoto()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case UpaxEnum.name.rawValue:
            return 89

        case UpaxEnum.selfie.rawValue:
            return 144

        default:
            return 350
        }
    }
}
