
import UIKit
import Photos
import MobileCoreServices

class PictureViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {

    @IBOutlet weak var pictureImageView: UIImageView!
    
    
    //画像のメンバ変数（画像のURLが入っている）
    var secondImage = UIImage()
    var selectDate = Date()
    @IBOutlet weak var choosePicture: UILabel!
    
    
    var mode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    
    
    // カメラロールから写真を選択する処理
  
    @IBAction func tapAlbum(_ sender: UIButton) {
    
        print("アルバムタップされたよ")
        
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
            
        }
        
    }
    
    
    
    // 写真を選んだ後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
      
//        //写真を文字列に変換
//        let assetURL:AnyObject = info[UIImagePickerControllerReferenceURL]! as AnyObject
//
//        let strURL:String = assetURL.description
//
//
//        if strURL != nil{
//            let url = URL(string: strURL as String!)
//            let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
//            let asset: PHAsset = (fetchResult.firstObject! as PHAsset)
//            let manager: PHImageManager = PHImageManager()
//            manager.requestImage(for: asset,targetSize: CGSize(width: 375, height: 563),contentMode: .aspectFill,options: nil) { (image, info) -> Void in
//                self.pictureImageView.image = image
//            }
//
//             pictureImageView.image = info[UIImagePickerControllerOriginalImage]! as! UIImage
//
//        }

        //カメラロールから選んだ後に呼ばれる処理
        // 選択した写真を取得する
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        // ビューに表示する
        self.pictureImageView.image = image
        

        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)



//        //カメラで撮影し終わった後に発動するメソッド
//        // imageViewに撮影した写真をセットするために変数に保存(ダウンキャスト変換P.302)
//        //P271
//        let takenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
//
//        // 画面上のimagViewに設定
//        pictureImageView.image = takenImage

        //ローカル変数に画像をぶち込む
        secondImage = image
        
        //UserDefaultから取得してきたスイッチの状態によって画像の表示/非表示を切り替える
        if secondImage !== nil{
            //labelを非表示
            choosePicture.isHidden = true
        }

        // 自分のデバイス（このプログラムが動いてる場所）に写真を保存（カメラロール）
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        //モーダルで表示した撮影モード画面を閉じる（前の画面に戻る）
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //セグエを使って、
    override func prepare(for segue: UIStoryboardSegue,sender: Any?) {
        
        if (segue.identifier == "addPicture"){
            let dvc:TableViewController = segue.destination as! TableViewController
            dvc.selectDate = selectDate
            dvc.mode = "A"
            dvc.secondImage = secondImage
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}
