
import UIKit
import CoreData
import Photos
import MobileCoreServices

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    
    
    var selectDate = Date()
    var selectedIndex = -1
    //TODO(内容)を格納する配列TableView 表示用
    var contentTitle:[NSDictionary] = []


    override func viewDidLoad() {
        super.viewDidLoad()
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
                let kurikaeshi :Date? = result.value(forKey:"kurikaeshi") as? Date
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
    
    //セルをスライドした時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            contentTitle.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //ボタンの文字や背景色を変えたい場合の設定
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            self.contentTitle.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with:  UITableViewRowAnimation.automatic)
        }
        deleteButton.backgroundColor = UIColor.red
        
        
//        print("##### データ削除開始 #####")
//        //iOS9以前の削除方法: フェッチして削除
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let managedObjectContext = appDelegate.managedObjectContext
//        
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
//        let predicate = NSPredicate(format: "price=%d", 999) //削除するオブジェクトの検索条件
//        fetchRequest.predicate = predicate
//        do {
//            let books = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Book]
//            for book in books {
//                managedObjectContext.deleteObject(book)
//            }
//            try managedObjectContext.save()
//        } catch let error as NSError {
//            fatalError("Failed to delete books: \(error)")
//        }
//        print("##### データ削除終了 #####")
        
        return [deleteButton]
    }
    
    
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
                cell.memoLabel.text = dic["memo"] as! String
                }
        }else{
            cell.titleLabel.text = dic["title"] as! String
            cell.memoLabel.text = dic["memo"] as! String
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
        
        let dvc:TableViewController = segue.destination as! TableViewController
        
        dvc.selectDate = selectDate
        
        if (segue.identifier == "showDetail"){
        
            dvc.mode = "E"
        }else if (segue.identifier == "newSegue"){
            
            dvc.mode = "A"
        }
        
//        if(segue.identifier == "showDetail") {
//            var vc = segue.destination as! TableViewController
//        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
