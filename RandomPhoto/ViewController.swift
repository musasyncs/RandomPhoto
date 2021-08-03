//
//  ViewController.swift
//  RandomPhoto
//
//  Created by Ewen on 2021/8/3.
//

import UIKit
import CoreML

class ViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "AI says it's a..."
        label.numberOfLines = 0
        return label
    }()
    
    private let answerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.layer.cornerRadius = 26
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        return button
    }()
    
    let colors: [UIColor] = [
        UIColor.init(red: 255/255, green: 205/255, blue: 178/255, alpha: 1),
        UIColor.init(red: 255/255, green: 199/255, blue: 174/255, alpha: 1),
        UIColor.init(red: 255/255, green: 193/255, blue: 170/255, alpha: 1),
        UIColor.init(red: 255/255, green: 187/255, blue: 166/255, alpha: 1),
        UIColor.init(red: 255/255, green: 180/255, blue: 162/255, alpha: 1),
        UIColor.init(red: 242/255, green: 166/255, blue: 159/255, alpha: 1),
        UIColor.init(red: 229/255, green: 152/255, blue: 155/255, alpha: 1),
        UIColor.init(red: 205/255, green: 142/255, blue: 148/255, alpha: 1),
        UIColor.init(red: 181/255, green: 131/255, blue: 141/255, alpha: 1)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.init(red: 255/255, green: 205/255, blue: 178/255, alpha: 1)
        
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.center = view.center
        view.addSubview(imageView)
        
        getRandomPhoto()
        
        button.frame = CGRect(
            x: 100,
            y: view.frame.size.height-100-view.safeAreaInsets.bottom,
            width: view.frame.size.width-200,
            height: 52
        )
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.addSubview(button)
        
        titleLabel.frame = CGRect(
            x: 20,
            y: view.frame.size.height / 2 + 130,
            width: view.frame.size.width-40,
            height: 100
        )
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        view.addSubview(titleLabel)
        
        answerLabel.frame = CGRect(
            x: 20,
            y: view.frame.size.height / 2 + 170,
            width: view.frame.size.width-40,
            height: 100
        )
        answerLabel.font = UIFont(name:"Optima", size: 20)
        view.addSubview(answerLabel)
    }
    
    func getRandomPhoto() {
        guard let data = try? Data(contentsOf: URL(string: "http://source.unsplash.com/random/300x300")!) else {
            return
        }
        imageView.image = UIImage(data: data)
    }
    
    func AorAn() {
        let firstAlphabet = answerLabel.text?.prefix(1)
        
        if (firstAlphabet == "a" || firstAlphabet == "e" || firstAlphabet == "i" || firstAlphabet == "o" || firstAlphabet == "u") {
            if let range = titleLabel.text?.range(of: "a...") {
                titleLabel.text?.replaceSubrange(range, with: "an...")
            }
        } else {
            if let range = titleLabel.text?.range(of: "an...") {
                titleLabel.text?.replaceSubrange(range, with: "a...")
            }
        }
    }
    
    private func analyzeImage(image: UIImage?) {
        guard let buffer = image?.resize(size: CGSize(width: 224, height: 224))?.getCVPixelBuffer() else {
            return
        }

        do {
            let model = try GoogLeNetPlaces(configuration: MLModelConfiguration())
            let output = try model.prediction(input: GoogLeNetPlacesInput(sceneImage: buffer))
            answerLabel.text = "\(output.sceneLabel) with \(Int(output.sceneLabelProbs[output.sceneLabel]! * 100))% confidence."
            AorAn()
        }
        catch {
            print(error.localizedDescription)
        }
    }
        
    @objc func didTapButton() {
        if answerLabel.text == "" {
            analyzeImage(image: imageView.image)
        } else {
            view.backgroundColor = colors.randomElement()
            
            getRandomPhoto()
            
            analyzeImage(image: imageView.image)
        }
    }
}
