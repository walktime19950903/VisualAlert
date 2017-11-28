
import UIKit

class PictureViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {

    @IBOutlet weak var pictureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //カメラボタンが押されたとき（撮影モードになる）
    @IBAction func tapCamera(_ sender: UIButton) {
        
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
    
    //カメラで撮影し終わった後に発動するメソッド
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // imageViewに撮影した写真をセットするために変数に保存(ダウンキャスト変換P.302)
        //P271
        let takenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // 画面上のimagViewに設定
        pictureImageView.image = takenImage
        
        // 自分のデバイス（このプログラムが動いてる場所）に写真を保存（カメラロール）
        UIImageWriteToSavedPhotosAlbum(takenImage, nil, nil, nil)
        
        //モーダルで表示した撮影モード画面を閉じる（前の画面に戻る）
        dismiss(animated: true, completion: nil)
        
        //info.plistの設定が必要（p.264）
        
        
        // iPhoneでエラーが出た場合、P.227をチェック！
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}
