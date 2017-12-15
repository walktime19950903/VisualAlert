
import UIKit
import CoreData
import Photos
import MobileCoreServices
import UserNotifications //ローカル通知に必要なフレームワーク

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newButton: UIButton!
    
    
    
    var selectDate = Date()
    var selectedIndex = -1
    //TODO(内容)を格納する配列TableView 表示用
    var contentTitle:[NSDictionary] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //通知機能の許可を促す処理
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert,.sound]){(granted,error) in }
        
        // 編集ボタンを左上に配置
        navigationItem.rightBarButtonItem = editButtonItem

        //角の丸み　border-radius
        newButton.layer.cornerRadius = 10
        
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
                
                
                print("title:\(title!),memo:\(memo!),saveDate:\(saveDate!),time:\(time!),kurikaeshi:\(kurikaeshi!),image:\(image)")
                
                var dic = ["memo":memo,"title":title,"saveDate":saveDate,"time":time,"kurikaeshi":kurikaeshi,"image":image] as[String : Any]
                contentTitle.append(dic as NSDictionary)
            }
        }catch{
        }
        //再読み込み
        tableView.reloadData()
    }
    
    //画面が表示された時発動
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        read()
        //画面の再読み込み
        tableView.reloadData()
    }
    
    
//ここからセルの編集モードのやつーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }


    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        let query: NSFetchRequest<TODO> = TODO.fetchRequest()
        
        var deleteCell = contentTitle[indexPath.row]
        let search = deleteCell["saveDate"] as! Date
        
        //絞り込み検索（ここを追加！！！！！！）---------------------------------
        //絞り込みの条件　saveDate = %@ のsaveDateはattribute名
        let saveDatePredicate = NSPredicate(format: "saveDate = %@", search as CVarArg)
        query.predicate = saveDatePredicate
        
        //----------------------------------------------------------------
        
        //        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
        self.contentTitle.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath as IndexPath], with:  UITableViewRowAnimation.automatic)
        
        //        }
        //        deleteButton.backgroundColor = UIColor.red
        
        
        do {
            let fetchResults = try viewContext.fetch(query)
            for result: AnyObject in fetchResults {
                let record = result as! NSManagedObject
                viewContext.delete(record)
            }
            try viewContext.save()
        } catch {
        }
        
                // 先にデータを更新する
                tableView.reloadData()
    }

    //並び替え可能なセルの設定
//    func tableView(_ tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//
//
//
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//
//        let targetTitle = contentTitle[sourceIndexPath.row]
//        if let index = contentTitle.index(of: targetTitle) {
//            contentTitle.remove(at: index)
//            contentTitle.insert(targetTitle, at: destinationIndexPath.row)
//        }
//         tableView.reloadData()
//    }
    
    //通常モードでは削除できないようにする
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return UITableViewCellEditingStyle.delete
        } else {
            return UITableViewCellEditingStyle.none
        }
    }
//ここまで編集モードのやつ--------------------------------------------------------------------------ーーーーーーーーーーーーーーーーーーーー〜〜ーーーーーーーー
    
    
    
    //MARK:TableView用の処理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentTitle.count
    }
    //3.リストに表示する文字列を決定し、表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //文字列を表示するセルの取得（セルの再利用）
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! customCell
        
        //表示したい文字の設定
        let dic = contentTitle[indexPath.row] as! NSDictionary
//        cell.titleLabel.text = dic["title"] as? String
//        cell.memoLabel.text = dic["memo"] as? String

        /*&& dic["memo"] as! String != nil && dic["title"] as! String != nil*/
        
        if dic["image"] as! String != ""{

            let url = URL(string: dic["image"] as! String)
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
            let asset: PHAsset = (fetchResult.firstObject! as PHAsset)
            let manager: PHImageManager = PHImageManager()
            manager.requestImage(for: asset,targetSize: CGSize(width: 74, height: 71),contentMode: .aspectFill,options: nil) { (image, info) -> Void in
                cell.cellImage.image = image
                cell.titleLabel.text = dic["title"] as! String
                
                //日付を文字列に変換
                let df = DateFormatter()
                df.dateFormat = "yyyy/MM/dd/HH:mm"
                
                //時差補正（日本時間に変更）
                df.locale = NSLocale(localeIdentifier: "ja_JP") as! Locale!
                
                cell.memoLabel.text = "通知時間：\(df.string(from: dic["time"] as! Date))"
                }
        }else{
            cell.titleLabel.text = dic["title"] as! String
//            cell.memoLabel.text = dic["saveDate"] as! String
            
            //日付を文字列に変換
            let df = DateFormatter()
            df.dateFormat = "yyyy/MM/dd/HH:mm"
            
            //時差補正（日本時間に変更）
            df.locale = NSLocale(localeIdentifier: "ja_JP") as! Locale!
            
            cell.memoLabel.text = "通知時間：\(df.string(from: dic["time"] as! Date))"
            
        }
        //文字を設定したセルを返す
        return cell
    }
    
    //セルをタップしたら発動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row + 1)行目がタップされたました。")
        
        var dic = contentTitle[indexPath.row] as! NSDictionary
        //選択された行番号を保存
        selectDate = dic["saveDate"] as! Date
        //セグエの名前を指定して画面遷移処理を発動
        performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    //セグエを使って、
    override func prepare(for segue: UIStoryboardSegue,sender: Any?) {
        
        if (segue.identifier == "showDetail"){
            let dvc:TableViewController = segue.destination as! TableViewController
            dvc.selectDate = selectDate
            dvc.mode = "Edit"
        }else if (segue.identifier == "newSegue"){
            let dvc1:PictureViewController = segue.destination as! PictureViewController
            dvc1.mode = "Add"
        }
        
//        if(segue.identifier == "showDetail") {
//            var vc = segue.destination as! TableViewController
//        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
