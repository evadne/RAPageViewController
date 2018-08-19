# RAPageViewController

Infinite scrolling and visual change reconciliation construct for paged content.

## Sample

Look at the [Sample App](https://github.com/evadne/RAPageViewController-Sample).

## What’s Inside

### `RAPageViewController`

`RAPageViewController` is built using view controller containment, and uses an internal `UIScrollView`. It exposes two public properties:

	@property (nonatomic, readwrite, weak) IBOutlet id<RAPageViewControllerDelegate> delegate;
	@property (nonatomic, readwrite, strong) IBOutletCollection(UIViewController) NSArray *viewControllers;
	
Connect the delegate outlet for the class to work in its intended way.  Otherwise, it’ll still show that one view controller from `viewControllers`, but that would probably not be very useful.

### `<RAPageViewControllerDelegate>`

You’ll find these methods:

	- (UIViewController *) pageViewController:(RAPageViewController *)pvc viewControllerBeforeViewController:(UIViewController *)vc;
	- (UIViewController *) pageViewController:(RAPageViewController *)pvc viewControllerAfterViewController:(UIViewController *)vc;

…they are basically the same thing you need to provide `UIPageViewController`.

Again, you can find a quick and dirty implementation in the [Sample App](https://github.com/evadne/RAPageViewController-Sample).  Page gap has also been implemented there as a freebie: the app comes with `RAPVCSViewController`, which shows a way to pad the views by overriding `-viewRectForPageRect:` and resizing the internal scroll view on view load.

### `RAPageCollectionViewController`

This is the controller you’ll want to use, in any case, if you are going to support a dynamic dataset.

Imagine if you’re using a Core Data stack with `NSFetchedResultsController` emitting change notifications:

* You’ll want pages to animate in and out.
* You’ll want to customize the presentation of pages.
* You’ll want the entire thing to work with autorotation.

There goes:

	@property (nonatomic, readwrite, weak) id<RAPageCollectionViewControllerDelegate> delegate;
	
	@property (nonatomic, readonly, strong) UICollectionView *collectionView;
	@property (nonatomic, readonly, strong) UICollectionViewFlowLayout *collectionViewLayout;
	
For more information, look at the sample app! [RAPVCSCollectionViewController](https://github.com/evadne/RAPageViewController-Sample/blob/develop/RAPageViewController-Sample/RAPVCSCollectionViewController.m) shows sample implementations for several methods that cover the basic operations:

* `rewind`: Move to the first page.
* `fastForward`: Move to the last page.
* `insertBefore`: Insert a page before the current page.
* `insertAfter`: Insert a page after the current page.
* `trash`: Delete the current page.

`RAPageCollectionViewController` delegates as much work on layout calculation as possible to the collection view, and uses existing constructs to provide update hooks.

It takes a delegate outlet, and asks for these key information:

* **How many pages in total?**  
	This allows the controller to prepare a scrollable area.

* **What’s the view controller at `index`?**  
	They will be queried dynamically, providing a chance to reuse (even) view controllers and avoid highly costly global instantiation for pages that are never visible.  

Again — the purpose of `RAPageCollectionViewController` is to provide a highly efficient, flexible way to present a bounded set of content, facilitating change reconciliation. You can’t use it to scroll thru a very large dataset without at least knowing the number of the data points, which is a defect for sure, but most of the existing paradigms for presenting a dataset wants an index and will just update the world when the total number of items changes.

As a freebie, let’s say you want to know exactly what page it is showing, and *how much is the offset for the page*. You want something more granular than a `NSUInteger`:

	@property (nonatomic, readwrite, assign) CGFloat displayIndex;	//	if no pages, it’ll be NAN, use isnan()
	- (void) setDisplayIndex:(CGFloat)displayIndex animated:(BOOL)animate completion:(void(^)(void))completionBlock;

The `displayIndex` provides you highly granular information about the current page as a floating point number.

It’s useful, at least for one of my use cases. :)

### `<RAPageCollectionViewControllerDelegate>`

This is where you provide all the data:

	- (NSUInteger) numberOfViewControllersInPageCollectionViewController:(RAPageCollectionViewController *)pageCollectionViewController;
	- (UIViewController *) viewControllerForPageAtIndex:(NSUInteger)index inPageCollectionViewController:(RAPageCollectionViewController *)pageCollectionViewController;

## Licensing

This project is in the public domain.  You can use it and embed it in whatever application you sell, and you can use it for evil.  However, it is appreciated if you provide attribution, by linking to the project page ([https://github.com/evadne/RAPageViewController](https://github.com/evadne/RAPageViewController)) from your application.

## Credits

*	[Evadne Wu](http://twitter.com/evadne) ([Info](http://radi.ws))
