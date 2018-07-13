//
//  CollectionViewTestTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/28/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class CollectionViewTestTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Outlets
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    // MARK: Basics
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imagesCollectionView.delegate = self
        self.imagesCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewTestCollectionViewCell", for: indexPath) as! CollectionViewTestCollectionViewCell
        
    }
}
