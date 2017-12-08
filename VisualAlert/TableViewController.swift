import UIKit
import CoreData
import Photos
import MobileCoreServices
import UserNotifications //ローカル通知に必要なフレームワーク
//import AssetsLibrary


class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate,UITextFieldDelegate {
    
 
    var selectDate:Date = Date()
    var contentTitle:[NSDictionary] = []
    var secondImage = ""
    
    var mode:String = ""
    var mode2:String = ""
    
    var saveDateID: Date = Date()
    
    //画像のメンバ変数（画像のURLが入っている）
    var letterImage = ""
    
    @IBOutlet weak var titleLabel: UITextField! //タイトル
    @IBOutlet weak var txtView: UITextView! //メモ欄
    @IBOutlet weak var pictureImageView: UIImageView! //メモ横の画像
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var kurikaeshiPicker: UIPickerView!
    @IBOutlet weak var kurikaeshiDetail: UILabel!
    
    @IBOutlet weak var gazouLabel: UILabel! //「画像選択」ラベル
    @IBOutlet weak var doneButton: UIBarButtonItem!//完了ボタン
    @IBOutlet weak var placeHolder: UILabel!//メモ欄プレースホルダー
    
    let texts = ["通知なし","1回","10分","30分","1時間","毎日","毎週","毎月"]
   
    //textviewがフォーカスされたら、メモ欄のプレースホルダーを非表示
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        placeHolder.isHidden = true
        return true
    }

    //textviewからフォーカスが外れて、TextViewが空だったらLabelを再び表示
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if(txtView.text.isEmpty){
            placeHolder.isHidden = false
        }
        // キーボードを隠す
        txtView.resignFirstResponder()
    }

    //タイトル欄の値が変わった時に呼び出される処理
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//                完了ボタンの押せるか押せないか
            if titleLabel.text == ""{
                    doneButton.isEnabled = false
                }else{
                    doneButton.isEnabled = true
//                    doneButton.tintColor = UIColor.default
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        //                完了ボタンの押せるか押せないか
        if titleLabel.text == ""{
            doneButton.isEnabled = false
        }else{
            doneButton.isEnabled = true
            //                    doneButton.tintColor = UIColor.default
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if secondImage == ""{
            gazouLabel.isHidden = false
        }else{
            gazouLabel.isHidden = true
        }
        
        if txtView.text == ""{
            placeHolder.isHidden = false
        }else if txtView.text != "" {
            placeHolder.isHidden = true
        }
        
//                完了ボタンの押せるか押せないか
        if titleLabel.text == ""{
            doneButton.isEnabled = false
        }
    }
    
    //画像選択を押した時の処理
    @IBAction func tapImage(_ sender: UITapGestureRecognizer) {
        print("イメージタップされたよ")
    }


    //完了ボタンが押された時発動
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        
        
        //Appdelegateを使う用意をしておく（インスタンス化）
        let appDelegate: AppDelegate = UIApplication.shared.delegate as!AppDelegate
        
        //エンティティを操作するためのオブジェクトを作成
        let viewContext = appDelegate.persistentContainer.viewContext
        
        //ToDoエンティティオブジェクトを作成
        let ToDo = NSEntityDescription.entity(forEntityName: "TODO", in: viewContext)
    
        
        if mode == "A"{
            
        //エンティティにレコード（行）を挿入するためのオブジェクトを作成
        let newRecord = NSManagedObject(entity: ToDo!, insertInto: viewContext)
        
        //どのエンティティからデータを取得してくるか設定（ToDoエンティティ）
        let query:NSFetchRequest<TODO> = TODO.fetchRequest()
            
        //値のセット
        newRecord.setValue(txtView.text, forKey: "memo")  //title列に文字をセット
        newRecord.setValue(Date(), forKey: "saveDate")      //saveDate列に現在日時をセット
        newRecord.setValue(titleLabel.text, forKey: "title")
        newRecord.setValue(secondImage, forKey:"image")
        newRecord.setValue(Date(), forKey: "kurikaeshi")
        newRecord.setValue(Date(), forKey: "time")
            
            //レコード（行）の即時保存
            do{
                    try viewContext.save()
                }catch{
            }
            
            
            
//       通知諸々の処理ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            
            //いま選択されている日時を文字列に変換
            var targetDate = datePicker.date
            
            var df = DateFormatter()
            df.dateFormat = "yyyy/MM/dd hh:mm:00"
            
            var strDate = df.string(from: targetDate)
            
            //Notificationのインスタンス作成
            let content = UNMutableNotificationContent()
            //タイトル設定
            content.title = "指定時間になりました"
            
            //本文設定
            content.body = "\(strDate)ですよ"
            
            //音設定
            content.sound = UNNotificationSound.default()
            
            //トリガー設定（いつ発火するか。今回はDatepickerで指定した日時）
            //        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 10, repeats: false)
            var dc = Calendar.current.dateComponents(in: TimeZone.current, from: targetDate)
            
            var setDc = DateComponents()
            setDc.year = dc.year!
            setDc.month = dc.month!
            setDc.day = dc.day!
            
            setDc.hour = dc.hour!
            setDc.minute = dc.minute!
            setDc.second = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: setDc, repeats: false)
            
            //リクエストの生成(通知IDをセット)
            let request = UNNotificationRequest.init(identifier: "ID_SpecificTime.\(saveDateID)", content: content, trigger: trigger)
            
            //通知の設定
            let center = UNUserNotificationCenter.current()
            center.add(request){(error) in }
            
            
            print("saveDateID\(saveDateID)")
//        ここまで繰り返しの処理ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            
        //セルが押されて遷移してきた時の処理
        }else if mode == "Edit"{
            
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
                    record.setValue(secondImage, forKey: "image")
                    
                    //更新を即時保存
                    try viewContext.save()
                }
            }catch{
                //エラーが発生したときに行う例外処理を書いておく場所
            }
        }
        if mode2 == "ShowBack"{
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
                    record.setValue(secondImage, forKey: "image")
                    
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
                
                if mode == "Edit"{
                    
                    secondImage = image!
                    
                } else if mode2 == "ShowBack"{
                    let url = URL(string: secondImage as String!)
                    let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
                    let asset: PHAsset = (fetchResult.firstObject! as PHAsset)
                    let manager: PHImageManager = PHImageManager()
                    manager.requestImage(for: asset,targetSize: CGSize(width: 128, height: 122),contentMode: .aspectFill,options: nil) { (image, info) -> Void in
                        self.pictureImageView.image = image
                    }
                }
                if secondImage != ""{
                    let url = URL(string: secondImage as String!)
                    let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
                    let asset: PHAsset = (fetchResult.firstObject! as PHAsset)
                    let manager: PHImageManager = PHImageManager()
                    manager.requestImage(for: asset,targetSize: CGSize(width: 128, height: 122),contentMode: .aspectFill,options: nil) { (image, info) -> Void in
                        self.pictureImageView.image = image
                    }
                }else{}
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
        
        
    if mode == "Edit" || mode2 == "ShowBack"{
        read()
            print("secondImageの中身:\(secondImage)")
        }else if mode == "A"{

            if secondImage != ""{
                let url = URL(string: secondImage as String!)
                let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
                let asset: PHAsset = (fetchResult.firstObject! as PHAsset)
                let manager: PHImageManager = PHImageManager()
                manager.requestImage(for: asset,targetSize: CGSize(width: 128, height: 122),contentMode: .aspectFill,options: nil) { (image, info) -> Void in
                    self.pictureImageView.image = image
                }
            }
            print("secondImageの中身\(secondImage)")
        }
        
        datePickerChanged()
        
        print("modeの中身\(mode)")
        print("mode2の中身\(mode2)")
        print(selectDate)
        print("TableViewController表示されたよ")
        print("受け取った行番号\(passedIndex)")
        
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
    
    //セグエを使って、
    override func prepare(for segue: UIStoryboardSegue,sender: Any?) {
        
        let dvc:PictureViewController = segue.destination as! PictureViewController
        dvc.selectDate = selectDate
        
        if (segue.identifier == "showImage"){
            
            if mode == "A"{
                dvc.mode2 = "Show"
                dvc.secondImage = secondImage
            }else if mode == "Edit" {
                dvc.mode = "E"
                dvc.mode2 = "Show"
                dvc.secondImage = secondImage
            }else if mode2 == "ShowBack"{
                dvc.mode2 = "Show"
                dvc.secondImage = secondImage
            }
        }
    }


    

}

