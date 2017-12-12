
import UIKit
import Photos
import MobileCoreServices

class PictureViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {

    @IBOutlet weak var pictureImageView: UIImageView! //でかい方のImageView
    @IBOutlet weak var nextButton: UIButton!
    
    
    //画像のメンバ変数（画像のURLが入っている）
    var secondImage = ""
    var selectDate = Date()
    @IBOutlet weak var choosePicture: UILabel!
    
    var cameramode = ""
    var mode = ""
    var mode2 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("pictureviewcontrollerのmodeの中身\(mode)")
        print("pictureviewcontrollerのmode2の中身\(mode2)")
        
//        if mode == "Edit2"{
        
            if secondImage != ""{
                let url = URL(string: secondImage as String!)
                let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
                let asset: PHAsset = (fetchResult.firstObject! as PHAsset)
                let manager: PHImageManager = PHImageManager()
                manager.requestImage(for: asset,targetSize: CGSize(width: 375, height: 563),contentMode: .aspectFill,options: nil) { (image, info) -> Void in
                    self.pictureImageView.image = image
                }
            }
//        }
        
        // imageViewにジェスチャーレコグナイザを設定する(ピンチ)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(sender:)))
        pictureImageView.addGestureRecognizer(pinchGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if secondImage != ""{
             nextButton.setTitle("次へ", for: .normal)
             choosePicture.isHidden = true
        }
        
        //角の丸み　border-radius
        nextButton.layer.cornerRadius = 15
    }

    // 画像の拡大率
    var currentScale:CGFloat = 1.0
    
    //画像縮小、拡大の関数
    @objc func pinchAction(sender: UIPinchGestureRecognizer) {
        // imageViewを拡大縮小する
        // ピンチ中の拡大率は0.3〜2.5倍、指を離した時の拡大率は0.5〜2.0倍とする
        switch sender.state {
        case .began, .changed:
            // senderのscaleは、指を動かしていない状態が1.0となる
            // 現在の拡大率に、(scaleから1を引いたもの) / 10(補正率)を加算する
            currentScale = currentScale + (sender.scale - 1) / 10
            // 拡大率が基準から外れる場合は、補正する
            if currentScale < 0.3 {
                currentScale = 0.3
            } else if currentScale > 2.5 {
                currentScale = 2.5
            }
            // 計算後の拡大率で、imageViewを拡大縮小する
            pictureImageView.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
        default:
            // ピンチ中と同様だが、拡大率の範囲が異なる
            if currentScale < 0.5 {
                currentScale = 0.5
            } else if currentScale > 2.0 {
                currentScale = 2.0
            }
            
            // 拡大率が基準から外れている場合、指を離したときにアニメーションで拡大率を補正する
            // 例えば指を離す前に拡大率が0.3だった場合、0.2秒かけて拡大率が0.5に変化する
            UIView.animate(withDuration: 0.2, animations: {
                self.pictureImageView.transform = CGAffineTransform(scaleX: self.currentScale, y: self.currentScale)
            }, completion: nil)
            
        }
    }
    
    
    // カメラロールから写真を選択する処理
  
    @IBAction func tapAlbum(_ sender: UIButton) {
    
        print("アルバムタップされたよ")
        
        // ユーザーに許可を促す.
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
        // カメラロールが利用可能か？
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = UIImagePickerControllerSourceType.photoLibrary
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
            
            self.cameramode = "cameraroll"
            }
        }
    }
    
    
    //カメラボタンが押されたとき（撮影モードになる）
    @IBAction func tapCamera(_ sender: UIButton) {
        print("cameraタップされたよ")
        //カメラが使えるかどうか判別するための情報を取得
        let camera = UIImagePickerControllerSourceType.camera
        
        //カメラが使える場合、撮影モードの画面を表示(p.262)
        //クラス名.メソッド名という形で使えるメソッド＝型メソッド（isSourceTypeAvailable）
        if UIImagePickerController.isSourceTypeAvailable(camera){
            //ImagePickerControllerオブジェクトを生成
            let picker = UIImagePickerController()
            //カメラモードに設定
            picker.sourceType = camera
            // デリゲートの設定（撮影後のメソッドを感知するため）
            picker.delegate = self
            //撮影モード画面の表示（モーダル）
            present(picker, animated: true, completion: nil)
            self.cameramode = "satsueimode"
        }
    }
    
    
    // カメラロールで写真を選んだ後、または撮影して保存した後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if cameramode == "cameraroll"{
        //写真を文字列に変換
        let assetURL:AnyObject = info[UIImagePickerControllerReferenceURL]! as AnyObject
        let strURL:String = assetURL.description


        if strURL != nil{
            let url = URL(string: strURL as String!)
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
            let asset: PHAsset = (fetchResult.firstObject! as PHAsset)
            let manager: PHImageManager = PHImageManager()
            manager.requestImage(for: asset,targetSize: CGSize(width: 375, height: 563),contentMode: .aspectFill,options: nil) { (image, info) -> Void in
                self.pictureImageView.image = image
            }
        }
            //ローカル変数にカメラロールで選んだ画像のURLをぶち込む
            self.secondImage = strURL
            print("セカンドイメージのURL\(secondImage)")
            
            // 写真を選ぶビューを引っ込める
            self.dismiss(animated: true)
        }
        
        
        //撮影した後のViewにImageを入れる処理
        let takenImage = info[UIImagePickerControllerOriginalImage]! as! UIImage
        pictureImageView.image = takenImage

        //撮影した写真のURLを取得する処理
        if cameramode == "satsueimode" {
        PHPhotoLibrary.shared().performChanges({
            var  createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: takenImage)
            
            let placeholder = createAssetRequest.placeholderForCreatedAsset
            
            print(placeholder?.localIdentifier)
            
            var id:String = (placeholder?.localIdentifier)!
            id = id.replacingOccurrences(of: "/L0/001", with: "")
            
            //撮影した写真のURLをメンバ変数secondImageにぶっ込む！！！
            var assetsurl = "assets-library://asset/asset.JPG?id=\(id)&ext=JPG"
            self.secondImage = assetsurl
            
        }, completionHandler: { success, error in
            if success {
                
            }
            else if let error = error {
                // Save photo failed with error
            }
            else {
                // Save photo failed with no error
            }
        })
        }
        
        //pictureImageViewの状態によってlabelの表示/非表示を切り替える
        if pictureImageView !== nil {
            //labelを非表示
            choosePicture.isHidden = true
        }
        //モーダルで表示した撮影モード画面を閉じる（前の画面に戻る）
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //セグエを使って、
    override func prepare(for segue: UIStoryboardSegue,sender: Any?) {
        
        let dvc:TableViewController = segue.destination as! TableViewController
        dvc.selectDate = selectDate
        
        if (segue.identifier == "addPicture"){
            if mode == "Add"{
                dvc.mode = "Add"
                dvc.secondImage = secondImage
            }else if mode == "Edit"{
                dvc.mode = "Edit"
                dvc.secondImage = secondImage
                print("dvc.secondImageの中身\(dvc.secondImage)")
            }else if mode == "Edit2"{
                dvc.mode = "Edit2"
                dvc.secondImage = secondImage
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}
