//
//  CollectionViewController.swift
//  Soundboard
//
//  Created by lefevluc on 04/04/2022.
//

import UIKit
import AVFoundation

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordMelodyButton: UIButton!
    @IBOutlet weak var txtName: UITextField!
    
    var audioRecorder : AVAudioRecorder? = nil
    var audioPlayer : AVAudioPlayer?
    var audioURL : URL?
    var sounds : [Int: Sound] = [:]
    var melodies : [Int: Melody] = [:]
    var lastSelected : Int? = nil
    var lastCell : CustomCollectionViewCell? = nil
    var indexMelody : Int = 0

    let couleurs : [UIColor] = [UIColor.green, UIColor.yellow, UIColor.orange, UIColor.red, UIColor.brown, UIColor.magenta, UIColor.purple, UIColor.blue, UIColor.cyan]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = true
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CustomCollectionViewCell")
        
        setUpRecorder()
        recordButton.isEnabled = false
    }
    
    //retourne le nombre de boutons a afficher pour la sound board
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    //Affiche chaque bouton avec une couleur de fond grise
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        cell.configure(indexPath.row, UIColor.gray)
        
        return cell
    }
    
    // Determine la taille de chaque cellule et le nombre a afficher par ligne
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width
        let height = collectionView.bounds.size.height
        return CGSize(width: (width - 50 ) / 3, height: (height - 60) / 3)
    }
    
    //Actions a effectuer lors de l'appui d'un bouton
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Numero de la derniere cellule selectionnee
        let previousCell = lastCell
        //Derniere cellule selectionnee
        let previousSelected = lastSelected
        
        //Recuperer le numéro de l'index de la cellule selectionnee
        lastSelected = indexPath.row
        //Recuperer la cellule selectionnee
        lastCell = (collectionView.cellForItem(at: indexPath) as! CustomCollectionViewCell)
        //On desactive la possiblite d'enregistrer tant qu'aucun bouton n'est selectionne
        recordButton.isEnabled = true
        
        //Jouer un son
        if sounds[lastSelected!] != nil {
            let sound = sounds[lastSelected!]
            lastCell!.configure(indexPath.row, UIColor.systemTeal)
            lastCell!.text(indexPath.row, "Selected")
            do {
                audioPlayer = try  AVAudioPlayer(data: sound!.audio!)
                audioPlayer?.play()
            } catch {
                
            }
        } else {
            lastCell!.configure(indexPath.row, UIColor.lightGray)
            lastCell!.text(indexPath.row, "Selected")
        }
        
        //On reinitialise la couleur et le texte de la derniere cellule selectionnee
        if previousCell != nil && previousSelected != nil {
            if previousCell != lastCell {
                if sounds[previousSelected!] == nil {
                    previousCell!.configure(indexPath.row, UIColor.gray)
                    previousCell!.text(indexPath.row, "")
                } else {
                    previousCell!.configure(indexPath.row, couleurs[previousSelected!])
                    previousCell!.text(indexPath.row, "")
                }
            }
        }
    }
    
    //Initialisation de l'enregistreur
    func setUpRecorder(){
        do {
            
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(AVAudioSession.Category.playAndRecord)
        try session.overrideOutputAudioPort(.speaker)
        try session.setActive(true)
        
            //Recuperation de l'URL pour les fichiers audio
            let basePath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
             audioURL = NSURL.fileURL(withPathComponents: pathComponents)
             print("##############################")
             print(audioURL!)
             print("##############################")
            
            //Parametrage de l'enregistreur
            var settings : [String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject
            settings[AVSampleRateKey] = 44100.0 as AnyObject
            settings[AVNumberOfChannelsKey] = 2 as AnyObject
            
            //Lancement de l'enregistreur
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder?.prepareToRecord()
            
        } catch let error as NSError {
            print(error)
        }
    
    }

    //Le bouton Record/Stop est appuye
    @IBAction func recordTapped(_ sender: Any) {
        
        //Si l'enregistreur enregistre
        if audioRecorder!.isRecording {
            //arreter l'enregistrement
            audioRecorder?.stop()
            recordButton.setTitle("Record", for: .normal)
            
            //On enregistre le son dans une entite Sound
            let context =  (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
            let sound = Sound(context:context)
            sound.indexToUse = Int64(lastSelected!)
            sound.audio = NSData(contentsOf: audioURL!) as Data?
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            navigationController?.popViewController(animated: true)
            sounds[lastSelected!] = sound
            
            //On modifie la couleur de la cellule pour montrer qu'un son y est enregistre
            lastCell!.configure(lastSelected!, couleurs[lastSelected!])
        } else {
            //lancer l'enregistrement
            audioRecorder?.record()
            recordButton.setTitle("Stop", for: .normal)
        }
    }
    
    //Le bouton Record melody/Stop est appuye
    @IBAction func recordMelodyTapped(_ sender: Any) {
        
        //Si l'enregistreur enregistre
        if audioRecorder!.isRecording {
            //arreter l'enregistrement
            audioRecorder?.stop()
            recordMelodyButton.setTitle("Record melody", for: .normal)
            
            //On enregistre la melodie dans une entite Melody
            let context =  (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
            let melody = Melody(context:context)
            melody.index = Int64(indexMelody)
            melody.name = "Melody "+String(indexMelody)
            indexMelody+=1
            melody.audio = NSData(contentsOf: audioURL!) as Data?
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            navigationController?.popViewController(animated: true)
            melodies[indexMelody] = melody
        } else {
            //lancer l'enregistrement
            audioRecorder?.record()
            recordMelodyButton.setTitle("Stop", for: .normal)
        }
    }
    
}
