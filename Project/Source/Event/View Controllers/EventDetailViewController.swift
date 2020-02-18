//
//  EventDetailViewController.swift
//  Rekall
//
//  Created by Steve on 9/27/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Contentful
import ContentfulRichTextRenderer

enum EventDetailSections: Int, CaseIterable {
    case hours
    case location
    case goodToKnow
    case richText
}

class EventDetailViewController: UIViewController {
    var event: Event? {
        didSet {
            if let vid = event?.venueId {
                venue = Venue.load(id: vid)
            }
            
            if let contentfulData = event?.contentfulData {
                set(contentful: contentfulData)
            }
        }
    }
    private var venue: Venue?
    private var contentfulDocument: RichTextDocument?
    
    func set(contentful data: Data) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)        
        do {
            contentfulDocument = try decoder.decode(RichTextDocument.self, from: data)
        } catch {
            print("ERROR: Failed to restore contentful data: \(error)")
        }
    }
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(EventHeaderView.nib, forHeaderFooterViewReuseIdentifier: EventHeaderView.identifier)
        tableView.register(DetailPointCell.nib, forCellReuseIdentifier: DetailPointCell.identifier)
        tableView.register(DetailLinkCell.nib, forCellReuseIdentifier: DetailLinkCell.identifier)
        tableView.register(RichTextCell.nib, forCellReuseIdentifier: RichTextCell.identifier)
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        setUpBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    func setUpBarItems() {
        let image = UIImage(named: "ShareAction")
        let share = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(shareTapped))
        navigationItem.rightBarButtonItems = [share]
    }
    
    @objc func shareTapped() {
        let shareSheet = UIActivityViewController(activityItems: shareItems(), applicationActivities: nil)
        present(shareSheet, animated: true, completion: nil)
    }
    
    func shareItems()->[Any] {
        var items = [Any]()
        let shareItemSource = EventShareItemSource()
        shareItemSource.event = event
        if let cachedImg = event?.firstCachedImage() {
            items.append(cachedImg)
        }
        items.append(shareItemSource)
        return items
    }

}

extension EventDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return EventDetailSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = EventDetailSections(rawValue: section)
        
        switch section {
        case .location:
            return (venue?.locationDescription == nil) ? 0 : 1
        case .hours:
            return (event?.startsAt == nil || event?.endsAt == nil) ? 0 : 1
        case .goodToKnow:
            return (venue?.attributes == nil) ? 0 : 1
        case .richText:
            return (contentfulDocument != nil) ? 1 : 0
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section =  EventDetailSections(rawValue: indexPath.section)
        
        switch section {
        case .location:
            return configLocationCell(tv: tableView, ip: indexPath)
        case .hours:
            return configHoursCell(tv: tableView, ip: indexPath)
        case .goodToKnow:
            return configGoodToKnowCell(tv: tableView, ip: indexPath)
        case .richText:
            return configRichTextCell(tv: tableView, ip: indexPath)
        case .none:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = EventDetailSections(rawValue: indexPath.section)
        
        if section == .location {
            if #available(iOS 13.0, *) {
                let sb = UIStoryboard(name: "OnSiteMap", bundle: nil)
                if let vc = sb.instantiateInitialViewController() as? OnSiteMapViewController {
                    vc.destinationVenue = venue
                    tabBarController?.tabBar.isHidden = true
                    navigationController?.pushViewController(vc, animated: true)
                }
            } else { showiOS13Required() }
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = EventDetailSections(rawValue: section) else { return nil }
        if section == .hours {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: EventHeaderView.identifier) as? EventHeaderView
            view?.event = event
            return view
        } else { return nil }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard let section = EventDetailSections(rawValue: section) else { return 0.01 }
        if section == .hours {
            return 540.0
        } else { return 0.01 }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = EventDetailSections(rawValue: section) else { return 0.0 }
        return (section == .hours) ? UITableView.automaticDimension : 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil //fixes an issue w/footers showing for every section
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01 //fixes an issue w/footers showing for every section
    }    
}

extension EventDetailViewController {
    
    func configHoursCell(tv: UITableView, ip: IndexPath)->DetailPointCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailPointCell.identifier, for: ip) as! DetailPointCell
        if let event = event {
            let items = [event.time(), event.isOpenDisplay()]
            let title = NSLocalizedString("Hours", comment: "title")
            cell.addLabels(items, title: title)
        }
        
        return cell
    }
    
    func configLocationCell(tv: UITableView, ip: IndexPath)->DetailLinkCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailLinkCell.identifier, for: ip) as! DetailLinkCell
        if let location = venue?.locationDescription {
            let title = NSLocalizedString("Location", comment: "title")
            cell.titleLabel?.text = title
            cell.setLink(text: location, addColor: true)
        }
        return cell
    }
    
    func configGoodToKnowCell(tv: UITableView, ip: IndexPath)->UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailPointCell.identifier, for: ip) as! DetailPointCell
        if let attrs = venue?.attributes {
            let title = NSLocalizedString("Good to Know", comment: "title")
            cell.addLabels(attrs, title: title)
        }
        return cell
    }
    
    func configRichTextCell(tv: UITableView, ip: IndexPath)->UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RichTextCell.identifier,
                                                 for: ip) as! RichTextCell
        
        cell.richText = contentfulDocument
        
        return cell
    }
}
