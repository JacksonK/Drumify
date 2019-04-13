//
//  SequencerViewController.swift
//  
//
//  Created by Jackson Kurtz on 4/5/19.
//

import UIKit

class SequencerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var sequencerCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var beat:Beat!
    
    //sets custom layout for collection view
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 8,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    
    //override var shouldAutorotate: Bool {
    //   return false
    //}
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        //let cell = collectionView.cellForItem(at: indexPath)
    
        beat.toggleCellActivation(index: indexPath.row, bar: 0)
        sequencerCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return beat.lanes.count * beat.lanes[0].bars[0].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomSequencerCell
        print("index path: ", indexPath)
        
        
        if beat.isCellActive(index: indexPath.row, bar: 0){
            cell.backgroundColor = .red
        }
        else {
            cell.backgroundColor = .gray
        }
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        sequencerCollectionView?.collectionViewLayout = columnLayout
        
        beat = Beat(name: "test")
        titleLabel.text = beat.name
    }
}
