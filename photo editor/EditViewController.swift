//
//  editViewController.swift
//  photo editor
//
//  Created by 林靖芳 on 2024/5/16.
//

import UIKit
import CoreImage.CIFilterBuiltins

class EditViewController: UIViewController, UITextViewDelegate, UIColorPickerViewControllerDelegate {
    
    
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var textSizeSlider: UISlider!
    @IBOutlet weak var textSize: UIButton!
    @IBOutlet weak var textColor: UIButton!
    @IBOutlet weak var textDetailStackView: UIStackView!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var rotate: UIButton!
    @IBOutlet weak var text: UIButton!
    @IBOutlet weak var filter: UIButton!
    @IBOutlet weak var filterDetail: UIStackView!
    @IBOutlet weak var adjustSlider: UISlider!
    @IBOutlet weak var backgroundColor: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
   
    var isTextColorSelect = true
    var deleteLabel = UILabel()
    var deleteArea = UIView()
    var textplaceholder = UILabel()
    var textview = UITextView()
    var rotateCount = 0.0
    var image:UIImage
    var currentColorMode:String = ""
    var lightValue:Float = 0
    var contrastValue:Float = 1
    var saturationValue:Float = 1
    var editImage:CIImage
    var textViewFontSize:CGFloat = 25
    var initialCenter: CGPoint = .zero
    
    
    init?(coder:NSCoder, image:UIImage){
        self.image = image
        self.editImage = CIImage(image: image)!
        super.init(coder: coder)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        textSizeSlider.isHidden = true
        textDetailStackView.isHidden = true
        photoImageView.image = image
        editImage = CIImage(image: photoImageView.image!)!
        filterDetail.isHidden = true
        adjustSlider.isHidden = true
        textSizeSlider.minimumValue = 10
        textSizeSlider.maximumValue = 50
        textSizeSlider.value = 25
        
        
        let pinchGestureForPhotoImage = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(_:)))
        photoImageView.addGestureRecognizer(pinchGestureForPhotoImage)
        
        //收鍵盤手勢
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    
    //照片縮放手勢
    @objc func scaleImage(_ gesture:UIPinchGestureRecognizer){
        
        var scale = gesture.scale
        let newTransform = photoImageView.transform.scaledBy(x: scale, y: scale)
        let newWidth = photoImageView.frame.width * scale
        let newHeight = photoImageView.frame.height * scale
        let minScale:CGFloat = 0.3
        let maxScale:CGFloat = 5
        
        if gesture.state == .began{
            initialCenter = photoImageView.center
        }
        
        if gesture.state == .changed{
            if newWidth >= photoImageView.bounds.width * minScale  && newWidth <= photoImageView.bounds.width * maxScale && newHeight >= photoImageView.bounds.height * minScale && newHeight <= photoImageView.bounds.height * maxScale{
                photoImageView.transform = newTransform
            }
            
            photoImageView.center = initialCenter
            
            scale = 1
            
        }
        
    }
    
   
    
    
    //收鍵盤function
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
  
    //顯示調整文字大小的slider
    @IBAction func showTextSize(_ sender: Any) {
        textSizeSlider.isHidden.toggle()
        textDetailStackView.isHidden = true
        textSizeSlider.value = Float(textViewFontSize)
        
        
    }
    
    //調整文字大小的slider
    @IBAction func adjustTextSize(_ sender: UISlider) {
        autoAdjustTextHeight()
        textViewFontSize = CGFloat(sender.value)
        textview.font = UIFont.systemFont(ofSize: textViewFontSize)
        
    }
    
    //調整文字功能，show文字選項
    @IBAction func showTextOption(_ sender: Any) {
        adjustSlider.isHidden = true
        filterDetail.isHidden = true
        textDetailStackView.isHidden.toggle()
        textSizeSlider.isHidden = true
        text.configuration?.baseForegroundColor = .systemYellow
        filter.configuration?.baseForegroundColor = .white
        rotate.configuration?.baseForegroundColor = .white
        backgroundColor.setImage(.background, for: .normal)
    }
    
    //更改背景顏色
    @IBAction func changeBackgroundColor(_ sender: Any) {
        adjustSlider.isHidden = true
        textSizeSlider.isHidden = true
        textDetailStackView.isHidden = true
        filterDetail.isHidden = true
        filter.configuration?.baseForegroundColor = .white
        text.configuration?.baseForegroundColor = .white
        rotate.configuration?.baseForegroundColor = .white
        backgroundColor.setImage(.backgroundYellow, for: .normal)
        
        let picker = UIColorPickerViewController()
        picker.delegate = self
        isTextColorSelect = false
        present(picker, animated: true, completion: nil)
    }
   
    
    //加文字
    @IBAction func addText(_ sender: Any) {
      
        if view.subviews.contains(textview) == false{
            textview.textAlignment = .center
            textview.backgroundColor = .clear
            textview.isUserInteractionEnabled = true
            
            textview.textColor = .black
            textview.allowsEditingTextAttributes = true
            textview.frame = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 250, height: 30)
            
            textview.center = CGPoint(x: photoImageView.frame.midX, y:photoImageView.frame.midY)
            textview.isScrollEnabled = false
            textview.delegate = self
            textview.textContainer.lineBreakMode = .byWordWrapping
            saveView.addSubview(textview)
            

            textplaceholder.text = "輸入文字"
            textview.addSubview(textplaceholder)
            
            textplaceholder.frame = CGRect(x: textview.bounds.midX - (textview.bounds.width/2)/2, y: textview.bounds.midY - (textview.bounds.height/2/2), width: textview.bounds.width/2, height: textview.bounds.height/2)
            textplaceholder.backgroundColor = .myPurple.withAlphaComponent(0.6)
            textplaceholder.textColor = UIColor.white
            textplaceholder.textAlignment = .center
            textplaceholder.font = UIFont.systemFont(ofSize: 16)
            
            deleteArea.frame = CGRect(x: 0, y: (mainStackView.frame.minY) - 50, width: view.frame.width, height: 50)
            
            deleteArea.backgroundColor = UIColor.clear
//            view.insertSubview(deleteArea, belowSubview: textSizeSlider)
        }
        
        //拖曳移動文字手勢
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanGestureOfText(_:)))
        textview.addGestureRecognizer(panGesture)
        
        //縮放文字手勢
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinchGestureOfText(_:)))
        textview.addGestureRecognizer(pinchGesture)
        
        
    }
    
    //調整文字顏色
    @IBAction func changTextColor(_ sender: Any) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        isTextColorSelect = true
        present(colorPicker, animated: true, completion: nil)
        
    }
    
    //UIColorPickerViewControllerDelegate的function，調整文字或背景顏色
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        let selectColor = viewController.selectedColor
        
        if isTextColorSelect{
            textview.textColor = selectColor
        }else{
            imageBackgroundView.backgroundColor = selectColor
        }
    }
    
    //縮放文字手勢的function
    @objc func didPinchGestureOfText(_ gesture: UIPinchGestureRecognizer){
        
        //把textview的中心點存入變數initialCenter
        if gesture.state == .began{
            initialCenter = textview.center
        }else if gesture.state == .changed{
            let scale = gesture.scale
            let newFontSizeByGesture = textViewFontSize * scale
            let newFontSize = min(newFontSizeByGesture,CGFloat(textSizeSlider.maximumValue))
            textview.font = UIFont.systemFont(ofSize: newFontSize)
            textSizeSlider.value = Float(newFontSize)
            textViewFontSize = newFontSize
            autoAdjustTextHeight()
            //手勢移動時，textview的center＝剛開始還沒移動的位子，讓textview不會因為放大縮小而改變中心點
            textview.center = initialCenter
            //將scale回歸為1，每次都從無縮放開始
            gesture.scale = 1
            
        }
        
    }

    
    
    //拖曳文字的function
    @objc func didPanGestureOfText(_ gesture: UIPanGestureRecognizer){
        
        
        let point = gesture.location(in:view)
        let translation = gesture.translation(in: view)
        
        
        //textview的superview是saveview，故轉換得知textview在view下的座標
        let textviewInView = textview.convert(textview.bounds, to: view)
        
       
        if let textview = gesture.view{
            if saveView.frame.contains(point){
                textview.center = CGPoint(x: textview.center.x + translation.x, y: textview.center.y + translation.y)
            }
            gesture.setTranslation(.zero, in: view)
        }
        
        if gesture.state == .changed{
            
            if textviewInView.intersects(deleteArea.frame){
                view.insertSubview(deleteArea, belowSubview: textSizeSlider)
                deleteLabel.textColor = .darkGray
                deleteLabel.font = UIFont.systemFont(ofSize: 12)

                deleteLabel.frame = CGRect(x: deleteArea.frame.midX - (40/2), y: deleteArea.frame.midY, width: 40, height: 20)
                view.addSubview(deleteLabel)
                deleteLabel.text = "刪除"
                deleteArea.backgroundColor = UIColor.red.withAlphaComponent(0.3)
                textDetailStackView.isHidden = true
                textSizeSlider.isHidden = true
                
            } else {
                deleteArea.removeFromSuperview()
                deleteLabel.text = ""
                
            }
        }
        
        
        if gesture.state == .ended {
            if textviewInView.intersects(deleteArea.frame){
                deleteArea.removeFromSuperview()
                deleteLabel.removeFromSuperview()
                textview.removeFromSuperview()
                textview.text = ""
                textViewFontSize = 25
            }
            
        }
        
    }

    //UITextViewDelegate的function，當文字改變時要做的事
    func textViewDidChange(_ textView: UITextView) {
        //textview有文字，且有placeholderLabel，將label移除
        if !textview.text.isEmpty{
            if textview.subviews.contains(textplaceholder) {
                textplaceholder.removeFromSuperview()
            }
        }
        //textview沒有文字，將textplaceholder加入
        if textview.text.isEmpty{
            textplaceholder.text = "輸入文字"
            textview.addSubview(textplaceholder)
        }
        
        //依照文字的內容自動調整textview的高度
        autoAdjustTextHeight()
     
        
    }
    //textview自動調整高度function
    func autoAdjustTextHeight(){
        let fixedWidth = textview.frame.width
        let newSize = textview.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textview.frame.size = CGSize(width: max(fixedWidth,newSize.width), height: newSize.height)
    }
        
    //照片旋轉function
    @IBAction func rotate(_ sender: Any) {
        adjustSlider.isHidden = true
        textSizeSlider.isHidden = true
        textDetailStackView.isHidden = true
        filterDetail.isHidden = true
        
        rotateCount += 1
        if rotateCount == 4 {
            rotateCount = 0
        }
        let oneDegree = CGFloat.pi/180
        photoImageView.transform = CGAffineTransform(rotationAngle: oneDegree*90*rotateCount)
        
        filter.configuration?.baseForegroundColor = .white
        text.configuration?.baseForegroundColor = .white
        rotate.configuration?.baseForegroundColor = .systemYellow
        backgroundColor.setImage(.background, for: .normal)
    }
    
    //顯示filter選項
    @IBAction func filterAction(_ sender: Any) {
        textSizeSlider.isHidden = true
        textDetailStackView.isHidden = true
        filter.configuration?.baseForegroundColor = .systemYellow
        text.configuration?.baseForegroundColor = .white
        rotate.configuration?.baseForegroundColor = .white
        backgroundColor.setImage(.background, for: .normal)
        
        if adjustSlider.isHidden && filterDetail.isHidden{
            filterDetail.isHidden = false
            

        }else if adjustSlider.isHidden{
            filterDetail.isHidden = true
        }
        
        else if !adjustSlider.isHidden{
            
            adjustSlider.isHidden = true
            filterDetail.isHidden = false
        }
        
    }
    
    //亮度/對比/飽和按鈕選擇
    @IBAction func filterAdjust(_ sender: UIButton) {
        
        filterDetail.isHidden = true
        adjustSlider.isHidden = false
        
        
        switch sender.tag{
            case 0:
                currentColorMode = kCIInputBrightnessKey
                adjustSlider.minimumValue = -1
                adjustSlider.maximumValue = 1
                adjustSlider.value = lightValue
                
                
            case 1:
                currentColorMode = kCIInputContrastKey
                adjustSlider.minimumValue = 0
                adjustSlider.maximumValue = 2
                adjustSlider.value = contrastValue
                
            case 2:
                currentColorMode = kCIInputSaturationKey
                adjustSlider.minimumValue = 0
                adjustSlider.maximumValue = 2
                adjustSlider.value = saturationValue
                
            default:
                break
                
        }
        
        
    }
    
    //slider調整亮度/對比/飽和
    @IBAction func lightAdjust(_ sender: UISlider) {
        
        switch currentColorMode {
            case kCIInputBrightnessKey:
                lightValue = sender.value
            case kCIInputContrastKey:
                contrastValue = sender.value
            case kCIInputSaturationKey:
                saturationValue = sender.value
            default:
                break
        }
        
        applyAdjustments()
    }
    
    
    //建立CIFilter實現並輸出調整後的照片
    func applyAdjustments() {
        
        let filter = CIFilter.colorControls()
        
        filter.setDefaults()
        filter.inputImage = editImage
        filter.brightness = lightValue
        filter.contrast = contrastValue
        filter.saturation = saturationValue
        
        if let outputImage = filter.outputImage {
            
            photoImageView.image = UIImage(ciImage: outputImage, scale: image.scale, orientation: image.imageOrientation)
            
        }
    }
    
    //照片儲存
    @IBAction func saveImage(_ sender: Any) {
        //擷取大小為saveView的大小
        let render = UIGraphicsImageRenderer(size: saveView.bounds.size)
        //in:從哪個座標開始畫
        let image = render.image { context in
            saveView.drawHierarchy(in: saveView.bounds, afterScreenUpdates: true)
        }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true)
        
        
    }
}


    


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


