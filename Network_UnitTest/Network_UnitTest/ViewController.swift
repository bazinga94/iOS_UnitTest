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
		networkManager.fetchRequest(url: JokesAPI.randomJokes.url, type: .GET) { (result: Result<JokeResponse, APIError>) in
			switch result {
				case .success(let model):
					print(model)
					DispatchQueue.main.async {
						let alert = UIAlertController.init(title: "Result", message: model.value.joke, preferredStyle: .alert)
						let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
						alert.addAction(cancel)
						self.present(alert, animated: false, completion: nil)
					}
				case .failure(let error):
					print(error)
			}
		}
	}
}

