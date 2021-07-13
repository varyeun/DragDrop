//
//  ViewController.swift
//  DragDrop
//
//  Created by Jini on 2021/07/12.
//

import UIKit

class ViewController: UIViewController {

    fileprivate var items: [String] = [
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collection = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CELL")
        collection.dragDelegate = self
        collection.dropDelegate = self
        collection.dragInteractionEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        view.addSubview(collection)
    }
    
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath {
            
            collectionView.performBatchUpdates({
                self.items.remove(at: sourceIndexPath.item)
                self.items.insert(item.dragItem.localObject as! String, at: destinationIndexPath.item)
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: nil)
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((collectionView.frame.width-8)/3), height: ((collectionView.frame.width-8)/3))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
        cell.backgroundColor = .white
        
        let image = UIImageView(image: UIImage(named: items[indexPath.row])!)
        image.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(image)
        image.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4).isActive = true
        image.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 4).isActive = true
        image.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -4).isActive = true
        image.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4).isActive = true
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        
        return cell
    }
}

extension ViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.items[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension ViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        
        if coordinator.proposal.operation == .move {
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
    }
}
