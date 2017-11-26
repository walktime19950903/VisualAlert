
import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var selectDate = String()
    var selectedIndex = -1
    
    var cellTitle:String? = ""
    var cellMemo:String? = ""
    
    //TODO(内容)を格納する配列TableView 表示用
    var contentTitle:[NSDictionary] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        read()
    
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
                
                let saveDate :Date? = result.value(forKey:"saveDate") as? Date
                let time :Date? = result.value(forKey:"time") as? Date
                
                print("title:\(title!),memo:\(memo!),saveDate:\(saveDate!),time:\(time!),kurikaeshi:\(kurikaeshi!)")
                
                var dic = ["memo":memo,"title":title,"saveDate":saveDate,"time":time,"kurikaeshi":kurikaeshi] as[String : Any]
                contentTitle.append(dic as NSDictionary)
                
            }
            
        }catch{
        
        }
        //再読み込み
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        read()
        
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
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteButton.backgroundColor = UIColor.red
        
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
        var dic = contentTitle[indexPath.row] as! NSDictionary
        cell.titleLabel.text = dic["title"] as! String
        cell.memoLabel.text = dic["memo"] as! String
        
        //文字を設定したセルを返す
        return cell
    }
    
    //セルをタップしたら発動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row + 1)行目がタップされたました。")
        
        //選択された行番号を保存
        selectedIndex = indexPath.row
        
        //文字列を表示するセルの取得（セルの再利用）
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! customCell
        
        //表示したい文字の設定
        var dic = contentTitle[indexPath.row] as! NSDictionary
        cell.titleLabel.text = dic["title"] as! String
        cell.memoLabel.text = dic["memo"] as! String
        
        
        
        cellTitle = cell.titleLabel.text
        cellMemo = cell.memoLabel.text
        
        print(cellTitle)
        
        
        //セグエの名前を指定して画面遷移処理を発動
        performSegue(withIdentifier: "showDetail", sender: nil)
        
    }
  
    
    //セグエを使って、
    override func prepare(for segue: UIStoryboardSegue,sender: Any?) {
//        //次の画面のインスタンス（オブジェクト）を取得
//        var dvc:TableViewController = segue.destination as!TableViewController
//        //次の画面のプロパティ（メンバ変数）passedIndexに選択された行番号を渡す
//        dvc.passedIndex = selectedIndex
        
        if(segue.identifier == "showDetail") {
            var vc = segue.destination as! TableViewController
            vc.param = cellTitle!
            vc.param2 = cellMemo!
        }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
