//
//  ViewController.swift
//  Network_UnitTest
//
//  Created by Jongho Lee on 2021/04/10.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

	@IBAction func networkTestButtonAction(_ sender: Any) {
		let networkManager = NetworkManager()
		let requestModel = JokesAPI()


		networkManager.fetch(request: requestModel) { (result: Result<JokesAPI.Response, APIError>) in
			switch result {
				case .success(let model):
					print(model)
					self.showAlert(message: model.value.joke)
				case .failure(let error):
					print(error)
			}
		}

//		networkManager.fetchRequest(url: JokesAPI.randomJokes.url, type: .GET) { (result: Result<JokeResponse, APIError>) in
//			switch result {
//				case .success(let model):
//					print(model)
//					self.showAlert(message: model.value.joke)
//				case .failure(let error):
//					print(error)
//			}
//		}
	}

	private func showAlert(message: String) {
		DispatchQueue.main.async {
			let alert = UIAlertController.init(title: "Result", message: message, preferredStyle: .alert)
			let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			alert.addAction(cancel)
			self.present(alert, animated: false, completion: nil)
		}
	}
}

