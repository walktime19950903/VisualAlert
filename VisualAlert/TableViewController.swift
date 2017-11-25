import UIKit
import CoreData

class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return texts.count
    }
    
    
    var sendText:String = ""
    var selectDate = String()
    var contentTitle:[NSDictionary] = []
    
    @IBOutlet weak var titleLabel: UITextField! //タイトル
    @IBOutlet weak var txtView: UITextView! //メモ欄
    @IBOutlet weak var pictureImageView: UIImageView! //メモ横の画像
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var kurikaeshiPicker: UIPickerView!
    @IBOutlet weak var kurikaeshiDetail: UILabel!

    
    
    
    let texts = ["通知なし","1回","10分","30分","1時間","毎日","毎週","毎月"]
    
    // カメラロールから写真を選択する処理
    @IBAction func choosePicture() {
        // カメラロールが利用可能か？
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = .photoLibrary
            // デリゲート
            pickerView.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
            // ビューに表示
            self.present(pickerView, animated: true)
        }
    }
    
    // 写真を選んだ後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // 選択した写真を取得する
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        // ビューに表示する
        self.pictureImageView.image = image
        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }
    
    //完了ボタンが押された時発動
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        
        //Appdelegateを使う用意をしておく（インスタンス化）
        let appDelegate: AppDelegate = UIApplication.shared.delegate as!AppDelegate
        
        //エンティティを操作するためのオブジェクトを作成
        let viewContext = appDelegate.persistentContainer.viewContext
        
        //ToDoエンティティオブジェクトを作成
        let ToDo = NSEntityDescription.entity(forEntityName: "TODO", in: viewContext)
        
        //エンティティにレコード（行）を挿入するためのオブジェクトを作成
        let newRecord = NSManagedObject(entity: ToDo!, insertInto: viewContext)
    
        //値のセット
        newRecord.setValue(txtView.text, forKey: "memo")  //title列に文字をセット
        newRecord.setValue(Date(), forKey: "saveDate")      //saveDate列に現在日時をセット
        newRecord.setValue(titleLabel.text, forKey: "title")

        newRecord.setValue(Date(), forKey: "kurikaeshi")
        newRecord.setValue(Date(), forKey: "time")
    
        //レコード（行）の即時保存
        do{
            try viewContext.save()
        } catch{
            //エラーが発生したときに行う例外処理を書いておく場所
            
        }
        
        //ひとつ前の画面に戻る
        self.navigationController?.popViewController(animated: true)

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
        
        
        //絞り込み検索（ここを追加！！！！！！）---------------------------------
        //絞り込みの条件　saveDate = %@ のsaveDateはattribute名
//        let saveDatePredicate = NSPredicate(format: "saveDate = %@", selectDate as CVarArg)
//        query.predicate = saveDatePredicate
//        
        //----------------------------------------------------------------
        
        
        do{
            //データを一括取得
            let fetchResults = try viewContext.fetch(query)
            
            //きちんと保存できてるか、一行ずつ表示（デバッグエリア）
            for result: AnyObject in fetchResults {
                let memo :String? = result.value(forKey:"memo") as? String
                let kurikaeshi :Date? = result.value(forKey:"kurikaeshi") as? Date
                let title :String? = result.value(forKey: "title") as? String
               
                let saveDate :Date? = result.value(forKey:"saveDate") as? Date
                let time :Date? = result.value(forKey:"time") as? Date
                
                print("絞り込んだ結果")
                print("title:\(title!) memo:\(memo!)kurikaeshi:\(kurikaeshi!)saveDate:\(saveDate!)time:\(time!)")
                
                var dic = ["title":title,"memo":memo,"kurikaeshi":kurikaeshi,"saveDate":saveDate,"time":time] as[String : Any]
                contentTitle.append(dic as NSDictionary)
                
            }
            
        }catch{
            
        }
    }

    //受け取った行番号を保存しておく変数
    var passedIndex:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        read()
        datePickerChanged()
        
        kurikaeshiPicker.delegate = self as! UIPickerViewDelegate
        kurikaeshiPicker.dataSource = self as! UIPickerViewDataSource
            
            print("二枚め表示されたよ")
            print("受け取った行番号\(passedIndex)")
            
        //表示したい文字の設定
        var dic = contentTitle[indexPath.row] as! NSDictionary
        titleLabel.text = dic["title"] as! String
        memoLabel.text = dic["memo"] as! String
        
            }
    
    func datePickerChanged () {
        detailLabel.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            toggleDatepicker()
        }
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var datePickerHidden = false
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if datePickerHidden && indexPath.section == 1 && indexPath.row == 1 {
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

