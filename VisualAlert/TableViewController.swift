import UIKit
import CoreData
import Photos
import MobileCoreServices
import UserNotifications //ローカル通知に必要なフレームワーク
//import AssetsLibrary


class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate,UITextFieldDelegate,UNUserNotificationCenterDelegate {

    
    //UserDefaultを操作するためのオブジェクトを作成
    var myDefault = UserDefaults.standard
    var appDomain:String = Bundle.main.bundleIdentifier!
    

 
    var selectDate:Date = Date()
    var contentTitle:[NSDictionary] = []
    var secondImage = ""
    
    var mode:String = ""
    var mode2:String = ""
    
    var kurikaeshiID = 0
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
    
    let texts = ["なし","10分","30分","1時間","毎日","毎週","毎月"]
   
    //textviewがフォーカスされたら、メモ欄のプレースホルダーを非表示
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        placeHolder.isHidden = true
        return true
    }
    
    
    // 改行ボタンを押した時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを隠す
        titleLabel.resignFirstResponder()
        return true
    }
    
    //textviewからフォーカスが外れて、TextViewが空だったらLabelを再び表示
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if(txtView.text.isEmpty){
            placeHolder.isHidden = false
        }else{
            placeHolder.isHidden = true
        }
        myDefault.set(txtView.text, forKey:"viewText")
        
        //plistファイルへの出力と同期する。
        myDefault.synchronize()
        
        // キーボードを隠す
        txtView.resignFirstResponder()
    }

    //タイトル欄の値が変わった時に呼び出される処理
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //ラベルの文字列を保存する。
        myDefault.set(titleLabel.text, forKey:"labelText")
//        myDefault.set(txtView.text, forKey:"viewText")
        
        //plistファイルへの出力と同期する。
        myDefault.synchronize()

        
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
        
        read()
        
        //デリゲート先を自分に設定する
        titleLabel.delegate = self
        txtView.delegate = self
        
        //文字列が保存されている場合はラベルに文字列を設定する。
        if let labelText = myDefault.string(forKey: "labelText") {
            titleLabel.text = labelText
        }
        if let viewText = myDefault.string(forKey:"viewText"){
            txtView.text = viewText
        }
        
        if secondImage == ""{
            gazouLabel.isHidden = false
        }else{
            gazouLabel.isHidden = true
        }
        
//                完了ボタンの押せるか押せないか
        if titleLabel.text == ""{
            doneButton.isEnabled = false
        }
        
        if txtView.text == ""{
            placeHolder.isHidden = false
        }else if txtView.text != "" {
            placeHolder.isHidden = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("kurikaeshiIDの中身：\(kurikaeshiID)")
        kurikaeshiPicker.selectRow(kurikaeshiID, inComponent: 0, animated: true)
        kurikaeshiDetail.text = texts[kurikaeshiID]
    }
    
    //画像選択を押した時の処理
    @IBAction func tapImage(_ sender: UITapGestureRecognizer) {
    }
    
    //フォアグラウンドで通知を出す機能
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler handlerBlock:
        (UNNotificationPresentationOptions) -> Void) {
        // Roll banner and sound alert
        handlerBlock([.alert, .sound])
    }


    //完了ボタンが押された時発動
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        
        
        NotificationCenter.default.removeObserver(self)
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        
        //Appdelegateを使う用意をしておく（インスタンス化）
        let appDelegate: AppDelegate = UIApplication.shared.delegate as!AppDelegate
        
        //エンティティを操作するためのオブジェクトを作成
        let viewContext = appDelegate.persistentContainer.viewContext
        
        //ToDoエンティティオブジェクトを作成
        let ToDo = NSEntityDescription.entity(forEntityName: "TODO", in: viewContext)
        
//       通知諸々の処理ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
        
        //いま選択されている日時を文字列に変換
        var targetDate = datePicker.date
        
        var df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd hh:mm:00"
        
        var strDate = df.string(from: targetDate)
        
        //Notificationのインスタンス作成
        let content = UNMutableNotificationContent()
        //タイトル設定
        content.title = "タイトル：\(titleLabel.text!)"
        
        //本文設定
        content.body = "メモ内容：\(txtView.text!)"
        
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
        
        // 5分間隔ごと
        let repeatTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        //通知時間リクエストの生成(通知IDをセット)
        let request = UNNotificationRequest.init(identifier: "ID_SpecificTime.\(saveDateID)", content: content, trigger: trigger)
        
        //繰り返しリクエストの生成(通知IDをセット)
        let repeatRequest = UNNotificationRequest.init(identifier: "ID_SpecificTime.\(saveDateID)", content: content, trigger: repeatTrigger)
        
        
        //通知の設定
        let center = UNUserNotificationCenter.current()
        center.add(request){(error) in }
        center.add(repeatRequest){(error) in }
        
        print("saveDateID\(saveDateID)")
//        ここまで繰り返しの処理ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
        

    
        
        if mode == "Add"{
            
        //エンティティにレコード（行）を挿入するためのオブジェクトを作成
        let newRecord = NSManagedObject(entity: ToDo!, insertInto: viewContext)
        
        //どのエンティティからデータを取得してくるか設定（ToDoエンティティ）
        let query:NSFetchRequest<TODO> = TODO.fetchRequest()
            
        //値のセット
        newRecord.setValue(txtView.text, forKey: "memo")  //title列に文字をセット
        newRecord.setValue(Date(), forKey: "saveDate")      //saveDate列に現在日時をセット
        newRecord.setValue(titleLabel.text, forKey: "title")
        newRecord.setValue(secondImage, forKey:"image")
        newRecord.setValue(kurikaeshiID, forKey: "kurikaeshi")
        newRecord.setValue(datePicker.date, forKey: "time")
            
            //レコード（行）の即時保存
            do{
                    try viewContext.save()
                }catch{
            }
            
            
        //セルが押されて遷移してきた時の処理
        }else if mode == "Edit" || mode == "Edit2"{
            
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
                    record.setValue(datePicker.date, forKey: "time")
                    record.setValue(kurikaeshiID, forKey: "kurikaeshi")
                    
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
        
        if mode == "Add" && secondImage != ""{
            let url = URL(string: secondImage as String!)
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
            let asset: PHAsset = (fetchResult.firstObject! as PHAsset)
            let manager: PHImageManager = PHImageManager()
            manager.requestImage(for: asset,targetSize: CGSize(width: 128, height: 122),contentMode: .aspectFill,options: nil) { (image, info) -> Void in
                self.pictureImageView.image = image
            }
        }
        
        
        do{
            //データを一括取得
            let fetchResults = try viewContext.fetch(query)
            
            //きちんと保存できてるか、一行ずつ表示（デバッグエリア）
            for result: AnyObject in fetchResults {
                let memo :String? = result.value(forKey:"memo") as? String
                let kurikaeshi :Int? = result.value(forKey:"kurikaeshi") as? Int
                let title :String? = result.value(forKey: "title") as? String
                let image :String? = result.value(forKey: "image") as? String
                let saveDate :Date? = result.value(forKey:"saveDate") as? Date
                let time :Date? = result.value(forKey:"time") as? Date
                
                print("絞り込んだ結果")
                print("title:\(title!) memo:\(memo!)kurikaeshi:\(kurikaeshi!)saveDate:\(saveDate!)time:\(time!),image:\(image!)")
                
                //メンバ変数にぶち込むkurikaeshiIDに
                kurikaeshiID = kurikaeshi!
                
                //セルが押されて遷移してきた時に表示する内容
                titleLabel.text = title
                txtView.text = memo
                datePicker.date = time!
//                kurikaeshiDetail.text = kurikaeshi
                
                if mode == "Edit"{
                    secondImage = image!
                   
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
                
                
                //日付を文字列に変換
                let df = DateFormatter()
                df.dateFormat = "yyyy/MM/dd hh:mm"
                
                //時差補正（日本時間に変更）
                df.locale = NSLocale(localeIdentifier: "ja_JP") as! Locale!
                
                detailLabel.text = df.string(from: dic["time"] as! Date)
                
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
        
        // Delegate を設定
        titleLabel.delegate = self
        
        // プレースホルダー
        titleLabel.placeholder = "必須項目"
        // テキストを全消去するボタンを表示
        titleLabel.clearButtonMode = .always
        // 改行ボタンの種類を変更
        titleLabel.returnKeyType = .done
        
        print("secondImageの中身:\(secondImage)")
        print("secondImageの中身\(secondImage)")
        print("デートピッカーの中身\(kurikaeshiDetail!)")
        
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        kurikaeshiID = row
    }
    
    //セグエを使って、
    override func prepare(for segue: UIStoryboardSegue,sender: Any?) {
        
        let dvc:PictureViewController = segue.destination as! PictureViewController
        dvc.selectDate = selectDate
        
        if (segue.identifier == "showImage"){
            
            if mode == "Add"{
                dvc.mode = "Add"
                dvc.secondImage = secondImage
            }else if mode == "Edit" {
                dvc.mode = "Edit2"
                dvc.secondImage = secondImage
            }else if mode == "Edit2"{
                dvc.mode = "Edit2"
                dvc.secondImage = secondImage
            }
        }
    }


    

}

