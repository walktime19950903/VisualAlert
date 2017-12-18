
import UIKit
import Photos
import MobileCoreServices
import CoreData

class PictureViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {

    @IBOutlet weak var pictureImageView: UIImageView! //でかい方のImageView
    @IBOutlet weak var nextButton: UIButton!
    
    //TODO(内容)を格納する配列TableView 表示用
    var contentTitle:[NSDictionary] = []
    
    //画像のメンバ変数（画像のURLが入っている）
    var secondImage = ""
    var selectDate:Date = Date()
    @IBOutlet weak var choosePicture: UILabel!
    
    var cameramode = ""
    var mode = ""
    var mode2 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        read()
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if secondImage != ""{
             nextButton.setTitle("次へ", for: .normal)
             choosePicture.isHidden = true
        }
        
        read()
        
        //角の丸み　border-radius
        nextButton.layer.cornerRadius = 15
    }
    
    //すでに存在するデータの読み込み処理
    func read(){
        //一旦からにする（初期化）
        contentTitle = []
        
        //AppDelegateを使う用意をしておく
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //エンティティを操作するためのオブジェクトを作成
        let viewContext = appDelegate.persistentContainer.viewContext
        
        //どのエンティティからデータを取得してくるか設定（ToDoエンティティ）
        let query:NSFetchRequest<TODO> = TODO.fetchRequest()
        
        //        絞り込み検索（ここを追加！！！！！！）---------------------------------
        //        絞り込みの条件　saveDate = %@ のsaveDateはattribute名
        let saveDatePredicate = NSPredicate(format: "saveDate = %@", selectDate as CVarArg)
        query.predicate = saveDatePredicate
        //        ----------------------------------------------------------------
        
        
        do{
            //データを一括取得
            let fetchResults = try viewContext.fetch(query)
            
            //きちんと保存できてるか、一行ずつ表示（デバッグエリア）
            for result: AnyObject in fetchResults {
                let memo :String? = result.value(forKey:"memo") as? String
                let kurikaeshi :String? = result.value(forKey:"kurikaeshi") as? String
                let title :String? = result.value(forKey: "title") as? String
                let image :String? = result.value(forKey: "image") as? String
                let saveDate :Date? = result.value(forKey:"saveDate") as? Date
                let time :Date? = result.value(forKey:"time") as? Date
                
                
                print("title:\(title!),memo:\(memo!),saveDate:\(saveDate!),time:\(time!),image:\(image!)")
                
                var dic = ["memo":memo,"title":title,"saveDate":saveDate,"time":time,"kurikaeshi":kurikaeshi,"image":image] as[String : Any]
                contentTitle.append(dic as NSDictionary)
            }
        }catch{
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
