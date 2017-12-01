import UIKit
import CoreData
import Photos
import MobileCoreServices

class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
    
 
    var selectDate:Date = Date()
    var contentTitle:[NSDictionary] = []

    var mode:String = ""
    
    //画像のメンバ変数（画像のURLが入っている）
    var letterImage = ""
    
    @IBOutlet weak var titleLabel: UITextField! //タイトル
    @IBOutlet weak var txtView: UITextView! //メモ欄
    @IBOutlet weak var pictureImageView: UIImageView! //メモ横の画像
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var kurikaeshiPicker: UIPickerView!
    @IBOutlet weak var kurikaeshiDetail: UILabel!


    
    let texts = ["通知なし","1回","10分","30分","1時間","毎日","毎週","毎月"]
   
    
    
    @IBAction func tapImage(_ sender: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {    //追記
            //写真ライブラリ(カメラロール)表示用のViewControllerを宣言
            let controller = UIImagePickerController()
            
            controller.delegate = self
            //新しく宣言したViewControllerでカメラとカメラロールのどちらを表示するかを指定
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //トリミング
            controller.allowsEditing = true
            //新たに追加したカメラロール表示ViewControllerをpresentViewControllerにする
            self.present(controller, animated: true, completion: nil)
        }
    }

    
    // 写真を選んだ後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //写真を文字列に変換
        let assetURL:AnyObject = info[UIImagePickerControllerReferenceURL]! as AnyObject
        
        let strURL:String = assetURL.description
        
//        //メンバ変数に写真のURLを保存
//        letterImage = strURL
//        print("写真のURL:\(letterImage)")
//
//        // ユーザーデフォルトを用意する
//        let myDefault = UserDefaults.standard
//
//        // データを書き込んで
//        myDefault.set(strURL, forKey: "selectedPhotoURL")
//
//        // 即反映させる
//        myDefault.synchronize()
        
        if strURL != nil{
            let url = URL(string: strURL as String!)
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
            let asset: PHAsset = (fetchResult.firstObject! as PHAsset)
            let manager: PHImageManager = PHImageManager()
            manager.requestImage(for: asset,targetSize: CGSize(width: 128, height: 122),contentMode: .aspectFill,options: nil) { (image, info) -> Void in
                self.pictureImageView.image = image
        }
//        pictureImageView.image = info[UIImagePickerControllerOriginalImage]! as! UIImage
        //閉じる処理
        picker.dismiss(animated: true, completion: nil)
        }
    }
    
    
    //完了ボタンが押された時発動
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        
        //Appdelegateを使う用意をしておく（インスタンス化）
        let appDelegate: AppDelegate = UIApplication.shared.delegate as!AppDelegate
        
        //エンティティを操作するためのオブジェクトを作成
        let viewContext = appDelegate.persistentContainer.viewContext
        
        //ToDoエンティティオブジェクトを作成
        let ToDo = NSEntityDescription.entity(forEntityName: "TODO", in: viewContext)
        

        if mode == "A" {
            
        //エンティティにレコード（行）を挿入するためのオブジェクトを作成
        let newRecord = NSManagedObject(entity: ToDo!, insertInto: viewContext)
        
        //どのエンティティからデータを取得してくるか設定（ToDoエンティティ）
        let query:NSFetchRequest<TODO> = TODO.fetchRequest()
            
        //値のセット
        newRecord.setValue(txtView.text, forKey: "memo")  //title列に文字をセット
        newRecord.setValue(Date(), forKey: "saveDate")      //saveDate列に現在日時をセット
        newRecord.setValue(titleLabel.text, forKey: "title")
        newRecord.setValue(letterImage, forKey:"image")
        newRecord.setValue(Date(), forKey: "kurikaeshi")
        newRecord.setValue(Date(), forKey: "time")
            
            //レコード（行）の即時保存
            do{
                    try viewContext.save()
                }catch{
            }
        //セルが押されて遷移してきた時の処理
        }else if mode == "E"{
            
            //どのエンティティからデータを取得してくるか設定（ToDoエンティティ）
            let query:NSFetchRequest<TODO> = TODO.fetchRequest()
            
            
            //絞り込み検索（ここを追加！！！！！！）---------------------------------
            //絞り込みの条件　saveDate = %@ のsaveDateはattribute名
            let saveDatePredicate = NSPredicate(format: "saveDate = %@", selectDate as CVarArg)
            query.predicate = saveDatePredicate
            
            //----------------------------------------------------------------
            //レコード（行）の即時保存
            do{
                //データを一括取得
                let fetchResults = try viewContext.fetch(query)
                
                //きちんと保存できてるか、一行ずつ表示（デバッグエリア）
                for result: AnyObject in fetchResults {
                    
                    //更新する対象のデータをNSManagedObjectにダウンキャスト変換そうすることにより編集が可能になる
                    let record = result as! NSManagedObject
                    
                    //更新したいデータのセット
                    record.setValue(titleLabel.text, forKey: "title")
                    record.setValue(txtView.text, forKey: "memo")
                    
                    //更新を即時保存
                    try viewContext.save()
                }
            }catch{
                //エラーが発生したときに行う例外処理を書いておく場所
            }
        }
        //最初の画面に戻る
        self.navigationController?.popToRootViewController(animated: true)
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
                let kurikaeshi :Date? = result.value(forKey:"kurikaeshi") as? Date
                let title :String? = result.value(forKey: "title") as? String
                let image :String? = result.value(forKey: "image") as? String
                let saveDate :Date? = result.value(forKey:"saveDate") as? Date
                let time :Date? = result.value(forKey:"time") as? Date
                
                print("絞り込んだ結果")
                print("title:\(title!) memo:\(memo!)kurikaeshi:\(kurikaeshi!)saveDate:\(saveDate!)time:\(time!),image:\(image!)")
                
                //セルが押されて遷移してきた時に表示する内容
                titleLabel.text = title
                txtView.text = memo
//                kurikaeshiPicker.delegate = kurikaeshi as! UIPickerViewDelegate
                
                var dic = ["title":title,"memo":memo,"kurikaeshi":kurikaeshi,"saveDate":saveDate,"time":time,"image":image] as[String : Any]
                contentTitle.append(dic as NSDictionary)
            }
        }catch{
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return texts.count
    }


    //受け取った行番号を保存しておく変数
    var passedIndex:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mode == "E"{
        read()
        }
        datePickerChanged()
        
        print(mode)
        
        print(selectDate)
        print("TableViewController表示されたよ")
        print("受け取った行番号\(passedIndex)")
        
//        titleLabel.text = param
//        txtView.text = param2
        kurikaeshiPicker.delegate = self as! UIPickerViewDelegate
        kurikaeshiPicker.dataSource = self as! UIPickerViewDataSource
        }

    
    
    func datePickerChanged () {
        detailLabel.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 3 && indexPath.row == 0 {
            toggleDatepicker()
        }
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var datePickerHidden = false
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if datePickerHidden && indexPath.section == 3 && indexPath.row == 1 {
            return 0
        }
        else {
//            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            return super.tableView(tableView, heightForRowAt: indexPath as! IndexPath)
        }
    }
    
    
    func toggleDatepicker() {
        datePickerHidden = !datePickerHidden
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    @IBAction func datePickerValue(sender: UIDatePicker) {
        datePickerChanged()
    }
    
    // pickerの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //pickerに表示する値を返すデリゲートメソッド.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return texts[row]
    }
    
    
    // pickerが選択された際に呼ばれるデリゲートメソッド.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        kurikaeshiDetail.text = texts[row]
    }
    

}

