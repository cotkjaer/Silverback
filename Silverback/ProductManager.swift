//
//  ProductManager.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation
import StoreKit

//MARK: - Products

extension NSUserDefaults
{
    public func setProductPurchaseStatus(purchaseStatus: Product.PurchaseStatus, forKey key: String)
    {
        setInteger(purchaseStatus.rawValue, forKey: key)
    }
    
    public func purchaseStatusForKey(key: String) -> Product.PurchaseStatus
    {
        return Product.PurchaseStatus(rawValue: integerForKey(key)) ?? Product.PurchaseStatus.None
    }
}

public extension SKProduct
{
    var localizedPrice : String?
        {
            let numberFormatter = NSNumberFormatter()
            
            numberFormatter.formatterBehavior = .Behavior10_4
            numberFormatter.numberStyle = .CurrencyStyle
            numberFormatter.locale = priceLocale
            
            return numberFormatter.stringFromNumber(price)
    }
}

private var productsCache = Dictionary<String, Product>()

public class Product: Equatable, Hashable
{
    public enum PurchaseStatus : Int, Comparable
    {
        case None = 0, PendingFetch, Purchasing, Deferred, Failed, Purchased
        
        init(transactionState: SKPaymentTransactionState?)
        {
            if let state = transactionState
            {
                switch state
                {
                case .Deferred : self = .Deferred
                case .Failed : self = .Failed
                case .Purchased, .Restored : self = .Purchased
                case .Purchasing : self = .Purchasing
                }
            }
            else
            {
                self = .None
            }
        }
    }
    
    public let productIdentifier : String
    internal var product: SKProduct?
    public var purchaseStatus : PurchaseStatus
        {
        didSet
        {
            // Only persist permanent status
            if purchaseStatus == .Purchased
            {
                let settings = NSUserDefaults.standardUserDefaults()
                
                settings.setProductPurchaseStatus(purchaseStatus, forKey: productIdentifier)
                settings.synchronize()
            }
        }
    }
    
    internal init(_ productIdentifier: String)
    {
        self.productIdentifier = productIdentifier
        self.purchaseStatus = NSUserDefaults.standardUserDefaults().purchaseStatusForKey(productIdentifier) ?? .PendingFetch// PurchaseStatus(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(productIdentifier)) ?? .PendingFetch
    }
    
    public var localizedTitle : String
        {
        if let localizedTitle = product?.localizedTitle
        {
            if !localizedTitle.isEmpty
            {
                return localizedTitle
            }
        }
        return NSLocalizedString(productIdentifier, comment: "Product Identifier")
    }
    
    public var localizedDescription : String? { return product?.localizedDescription }
    public var localizedPrice : String? { return product?.localizedPrice }
    
    public func purchase() throws
    {
        switch purchaseStatus
        {
        case .Deferred:
            throw NSError(domain: "In-App Purchase", code: 4, description: "Waiting for purchase to be approved")
            
        case .Purchased:
            throw NSError(domain: "In-App Purchase", code: 3, description: "Already purchased")
            
        case .Purchasing:
            throw NSError(domain: "In-App Purchase", code: 0, description: "Already in the process of purchasing")
            
        default:
            
            if !SKPaymentQueue.canMakePayments()
            {
                purchaseStatus >?= .Failed
                throw NSError(domain: "In-App Purchase", code: 1, description: "Cannot make payment", reason: "Payments are disables in Settings")
            }
            
            if let skProduct = product
            {
                purchaseStatus = .Purchasing
                SKPaymentQueue.defaultQueue().addPayment(SKPayment(product: skProduct))
            }
            else
            {
                purchaseStatus >?= .PendingFetch
            }
        }
    }
    
    //MARK: Hashable
    
    public var hashValue : Int { return productIdentifier.hashValue }
}

//MARK: - Factory
public extension Product
{
    public class func productWithIdentifier(identifier: String) -> Product
    {
        if let product = productsCache[identifier]
        {
            return product
        }
        else
        {
            let product = Product(identifier)
            productsCache[identifier] = product
            return product
        }
    }
}


//MARK: - Equatable

public func ==(lhs: Product, rhs: Product) -> Bool
{
    return lhs.productIdentifier == rhs.productIdentifier
}

// MARK: - Comparable

public func <(lhs: Product.PurchaseStatus, rhs: Product.PurchaseStatus) -> Bool
{
    return lhs.rawValue < rhs.rawValue
}

public let ProductsFetchSuccededNotificationName = "ProductsFetchSuccededNotification"
public let ProductsFetchFailedNotificationName = "ProductsFetchFailedNotification"
public let ProductsStatesUpdatedNotificationName = "ProductsStatesUpdatedNotification"
public let ProductsRestoreSuccededNotificationName = "ProductsRestoreSuccededNotification"
public let ProductsRestoreFailedNotificationName = "ProductsRestoreFailedNotification"

public class ProductManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    public let products : Set<Product>
    
    public required init(productIdentifiers: Set<String>)
    {
        products = productIdentifiers.map( { Product.productWithIdentifier($0) } )
        
        super.init()
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    deinit
    {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    //MARK: - Lookup
    
    public func productWithIdentifier(identifier: String) -> Product?
    {
        return products.filter({ $0.productIdentifier == identifier }).first
    }
    
    //MARK: - SKProductsRequestDelegate
    
    private var allFetched : Bool { return products.all { $0.product != nil } }
    
    private var request : SKProductsRequest?
    
    private var fetching : Bool { return request != nil }
    
    public func fetchProducts()
    {
        if !fetching && !allFetched
        {
            let productsToFetch = products.sift { $0.product == nil }
            
            productsToFetch.forEach { $0.purchaseStatus >?= .PendingFetch }
            
            request = SKProductsRequest(productIdentifiers: productsToFetch.map( { $0.productIdentifier }))
            request?.delegate = self
            request?.start()
        }
    }
    
    public func request(request: SKRequest, didFailWithError error: NSError)
    {
        self.request = nil
        
        error.presentAsAlert()
        
        NSNotificationCenter.defaultCenter().postNotificationName(ProductsFetchFailedNotificationName, object: self)
    }
    
    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse)
    {
        self.request = nil
        
        if response.products.isEmpty
        {
            self.request(request, didFailWithError: NSError(domain: "In-App Purchase", code: 0, description: "No Products found, invalid identifiers: (" + response.invalidProductIdentifiers.joinWithSeparator(", ") + ")"))
        }
        else
        {
            for product in response.products
            {
                productWithIdentifier(product.productIdentifier)?.product = product
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(ProductsFetchSuccededNotificationName, object: self)
        }
        
        for product in products.filter( { $0.purchaseStatus == .PendingFetch })
        {
            product.purchaseStatus = .None
            tryCatchLog(product.purchase)
        }
    }
    
    //MARK: - SKPaymentTransactionObserver (restore)
    
    public var canRestore : Bool
        {
            if restored || restoring
            {
                return false
            }
            
            return products.any { $0.purchaseStatus == .None }// !products.filter({ $0.purchaseStatus == .None }).isEmpty
    }
    
    public private(set) var restored = false
    
    public private(set) var restoring = false
    
    public func restoreProducts()
    {
        if canRestore
        {
            restoring = true
            
            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        }
    }
    
    public func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError)
    {
        restoring = false
        
        NSNotificationCenter.defaultCenter().postNotificationName(ProductsRestoreFailedNotificationName, object: self)
        
        error.presentAsAlert()
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue)
    {
        restoring = false
        restored = true
        
        NSNotificationCenter.defaultCenter().postNotificationName(ProductsRestoreSuccededNotificationName, object: self)
    }
    
    //MARK: - SKPaymentTransactionObserver (purchase)
    
    public var purchasing : Bool { return products.any { $0.purchaseStatus == .Purchasing } }// !products.filter({ $0.purchaseStatus == .Purchasing }).isEmpty }
    
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions
        {
            let id = transaction.payment.productIdentifier
            
            if let product = productWithIdentifier(id)
            {
                product.purchaseStatus >?= Product.PurchaseStatus(transactionState: transaction.transactionState)
                
                debugPrint("got transaction state \(transaction.transactionState) for product \(transaction.payment.productIdentifier)")
                
                switch transaction.transactionState
                {
                case .Deferred:
                    queue.finishTransaction(transaction)
                    
                case .Failed:
                    transaction.error?.presentAsAlert()
                    product.purchaseStatus = .None
                    queue.finishTransaction(transaction)
                    
                case .Purchased:
                    queue.finishTransaction(transaction)
                    
                case .Purchasing:
                    debugPrint(".Purchasing - not calling 'queue.finishTransaction(transaction)'")
                    
                case .Restored:
                    queue.finishTransaction(transaction)
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(ProductsStatesUpdatedNotificationName, object: self)
    }
    
    public func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction])
    {
        debugPrint("Removed transactions \(transactions)")
    }
}

// MARK: - Products View Controller

public protocol ProductsViewController : class
{
    var productManager : ProductManager? { get set }
}

extension UIViewController
{
    public func presentPurchaseAlert(productManager: ProductManager, productIdentifier: String, completion: (() -> ())?)
    {
        let alert : UIAlertController
        
        if let product = productManager.productWithIdentifier(productIdentifier)
        {
           alert = UIAlertController(title: product.localizedTitle, message: product.localizedDescription, preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: product.localizedPrice, style: .Default, handler: { (action) -> Void in
                
                do
                {
                    try product.purchase()
                }
                catch let e as NSError
                {
//                    debugPrint("\(e)")
                    e.presentAsAlert()
                }
                
            }))

            alert.addAction(UIAlertAction(title: UIKitLocalizedString("Cancel"), style: .Cancel, handler: nil))
        }
        else
        {
            alert = UIAlertController(title: "Error?", message: "Unknown product \"\(productIdentifier)\"", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: UIKitLocalizedString("Done"), style: .Cancel, handler: nil))
        }

        presentViewController(alert, animated: true, completion: completion)
    }
}


// MARK: - Products Collection View

// MARK: Cell

public class ProductsCollectionViewCell : UICollectionViewCell
{
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var detailLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView?
}


// MARK: Controller

public class ProductsCollectionViewController: UICollectionViewController, ProductsViewController
{
    let nhm = NotificationHandlerManager()
    
    public var productManager : ProductManager?//(productIdentifiers: Set())
        {
            didSet
            {
                if oldValue != nil
                {
                    nhm.deregisterAll()
                }
                
                if let manager = productManager
                {
                    nhm.onAny(from: manager) {
                        self.refreshUI()
                    }
                }
           
                productManager?.fetchProducts()
                
                updateData()
                
                refreshUI()
        }
    }
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    // MARK: - data

    var data = Array<Array<Product>>()
    
    func updateData()
    {
        if let sortedProducts = productManager?.products.sort( { $0.productIdentifier < $1.productIdentifier } )
        {
            data = [sortedProducts]
        }
        else
        {
            data = []
        }
    }
    
    
    func productForIndexPath(indexPath: NSIndexPath) -> Product?
    {
        return data.get(indexPath.section)?.get(indexPath.item)
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    private let CellReuseIdentifier = "ProductCell"
    
    func cellReuseIdentifierForProduct(product: Product) -> String
    {
        return product.productIdentifier + CellReuseIdentifier
    }
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if let product = productForIndexPath(indexPath)
        {
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifierForProduct(product), forIndexPath: indexPath) as? ProductsCollectionViewCell
            {
                cell.titleLabel?.text = product.localizedTitle
                cell.detailLabel?.text = product.localizedDescription
                
                var color = UIColor.darkTextColor()
                
                switch product.purchaseStatus
                {
                case .Deferred:
                    cell.statusLabel?.text = nil//NSLocalizedString("Purchasing", comment:"Purchase deferred")
                    cell.activityIndicatorView?.startAnimating()
                    
                case .Failed:
                    cell.statusLabel?.text = NSLocalizedString("!", comment: "Purchase failed")
                    color = UIColor.redColor().darkerColor()
                    cell.activityIndicatorView?.stopAnimating()
                    
                case .Purchased:
                    cell.statusLabel?.text = NSLocalizedString("✓", comment: "Purchased")
                    color = UIColor.greenColor().darkerColor()
                    cell.activityIndicatorView?.stopAnimating()
                    
                    
                case .Purchasing:
                    cell.statusLabel?.text = nil//NSLocalizedString("Purchasing", comment: "")
                    cell.activityIndicatorView?.startAnimating()
                    
                    
                case .PendingFetch:
                    cell.titleLabel?.text = nil
                    cell.detailLabel?.text = nil
                    cell.statusLabel?.text = nil //NSLocalizedString("Fetching", comment: "")
                    cell.activityIndicatorView?.startAnimating()
                    
                case .None:
                    cell.statusLabel?.text = product.localizedPrice
                    cell.activityIndicatorView?.stopAnimating()
                    
                    color = view.tintColor
                }
                
                //            cell.statusLabel?.textColor = color
                
                cell.layer.borderColor = color.CGColor
                cell.titleLabel?.backgroundColor = color
                cell.titleLabel?.textColor = UIColor.whiteColor()
                cell.statusLabel?.backgroundColor = color
                cell.statusLabel?.textColor = UIColor.whiteColor()
                
                return cell
            }
            
            fatalError("could not get product or cell with identifier \(cellReuseIdentifierForProduct(product))")
        }
        
        fatalError("could not get product or product for indexPath \(indexPath)")
    }
    
    // MARK: UICollectionViewDelegate
    
    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        if let product = productForIndexPath(indexPath)
        {
            do
            {
                try product.purchase()
            }
            catch let e as NSError
            {
                e.presentAsAlert()
            }
        }
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    // MARK: - Cancel Button
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem?
    @IBOutlet weak var cancelButton: UIButton?
    
    @IBAction func cancelButtonPressed()
    {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Restore Button
    
    @IBOutlet weak var restorePurchasesBarButton: UIBarButtonItem?
    @IBOutlet weak var restorePurchasesButton: UIButton?
    
    @IBAction func restorePurchasesButtonPressed()
    {
        productManager?.restoreProducts()
        refreshRestorePurchasesButton()
    }
    
    // MARK: - UI
    
    func refreshUI(animated animated: Bool = false)
    {
        refreshCollectionView(animated: animated)
        refreshRestorePurchasesButton(animated: animated)
    }

    func refreshRestorePurchasesButton(animated animated: Bool = false)
    {
        let enabled = productManager?.canRestore == true
        
        restorePurchasesButton?.enabled = enabled
        restorePurchasesBarButton?.enabled = enabled
    }

    // TODO: update animated
    func refreshCollectionView(animated animated: Bool = false)
    {
        self.collectionView?.reloadData()
    }
}



// MARK: - Products Table View

// MARK: Cell

class ProductsTableViewCell: UITableViewCell
{
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        setup()
    }
    
    func setup()
    {
        selectionStyle = .None
    }
    

    override func setHighlighted(highlighted: Bool, animated: Bool)
    {
        
    }
}

// MARK: Controller

public class ProductsTableViewController: UITableViewController, ProductsViewController
{
    let nhm = NotificationHandlerManager()
    
    public var productManager : ProductManager?
        {
        didSet
        {
            if oldValue != nil
            {
                nhm.deregisterAll()
            }
            
            if let manager = productManager
            {
                nhm.onAny(from: manager) {
                    self.refreshUI()
                }
            }
            
            productManager?.fetchProducts()
            
            updateData()
            
            refreshUI()
        }
    }
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        refreshUI()
    }
    
    // MARK: - data
    
    var data = Array<Array<Product>>()
    
    func updateData()
    {
        if let sortedProducts = productManager?.products.sort( { $0.productIdentifier < $1.productIdentifier } )
        {
            data = [sortedProducts]
        }
        else
        {
            data = []
        }
    }
    
    func productForIndexPath(indexPath: NSIndexPath) -> Product?
    {
        return data.get(indexPath.section)?.get(indexPath.item)
    }
    
    
    // MARK: UITableViewDataSource
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    private let CellReuseIdentifier = "ProductCell"
    
    func cellReuseIdentifierForProduct(product: Product) -> String
    {
        return product.productIdentifier + CellReuseIdentifier
    }
    
    func activityIndicator() -> UIActivityIndicatorView
    {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if let product = productForIndexPath(indexPath)
        {
            let cellReuseIdentifier = cellReuseIdentifierForProduct(product)
            
            if let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as? ProductsTableViewCell
            {
                cell.textLabel?.text = product.localizedTitle
                cell.detailTextLabel?.text = product.localizedDescription
                

                switch product.purchaseStatus
                {
                case .Deferred:
                    cell.accessoryView = activityIndicator()
                    
                case .Failed:
                    cell.accessoryView = UILabel(text: NSLocalizedString("!", comment: "Purchase failed"), color: UIColor.redColor().darkerColor())
                    
                case .Purchased:
                    cell.accessoryType = .Checkmark
                    
                case .Purchasing:
                    cell.accessoryView = activityIndicator()
                    
                case .PendingFetch:
                    cell.accessoryView = activityIndicator()
                    
                case .None:
                    cell.accessoryView = UILabel(text: product.localizedPrice, color: UIColor.darkTextColor())
                }

                return cell
            }
            
            fatalError("could not get product or cell with identifier \(cellReuseIdentifierForProduct(product))")
        }
        
        fatalError("could not get product or product for indexPath \(indexPath)")
    }
    
    // MARK: UITableViewDelegate
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let product = productForIndexPath(indexPath)
        {
            do
            {
                try product.purchase()
            }
            catch let error as NSError
            {
                error.presentAsAlert()
            }
        }
    }
    
    // MARK: - Cancel Button
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem?
    @IBOutlet weak var cancelButton: UIButton?
    
    @IBAction func cancelButtonPressed()
    {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Restore Button
    
    @IBOutlet weak var restorePurchasesBarButton: UIBarButtonItem?
    @IBOutlet weak var restorePurchasesButton: UIButton?
    
    @IBAction func restorePurchasesButtonPressed()
    {
        productManager?.restoreProducts()
        refreshRestorePurchasesButton()
    }
    
    // MARK: - UI
    
    func refreshUI(animated animated: Bool = false)
    {
        refreshTableView(animated: animated)
        refreshRestorePurchasesButton(animated: animated)
    }
    
    func refreshRestorePurchasesButton(animated animated: Bool = false)
    {
        let enabled = productManager?.canRestore == true
        
        restorePurchasesButton?.enabled = enabled
        restorePurchasesBarButton?.enabled = enabled
    }
    
    // TODO: update animated
    func refreshTableView(animated animated: Bool = false)
    {
        self.tableView?.reloadData()
    }
}