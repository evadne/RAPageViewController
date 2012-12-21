# RAPageViewController

Reimplements the redacted bits for expressiveness at expense of naïvety.  Allows sliding view controllers around in a very, very flat fashion.

## Sample

Look at the [Sample App](https://github.com/evadne/RAPageViewController-Sample).

## What’s Inside

You can find an `RAPageViewController`, which basically exposes two properties:

	@property (nonatomic, readwrite, weak) IBOutlet id<RAPageViewControllerDelegate> delegate;
	@property (nonatomic, readwrite, strong) IBOutletCollection(UIViewController) NSArray *viewControllers;
	
In a nutshell, you must connect the delegate outlet for the class to work in its intended way.  Otherwise, it’ll still show that one view controller from `viewControllers`, but that would probably not be very useful.

In `RAPageViewControllerDelegate`, you’ll find:

	- (UIViewController *) pageViewController:(RAPageViewController *)pvc viewControllerBeforeViewController:(UIViewController *)vc;
	- (UIViewController *) pageViewController:(RAPageViewController *)pvc viewControllerAfterViewController:(UIViewController *)vc;

…they are basically the same thing you need to provide `UIPageViewController`.

Again, you can find a quick and dirty implementation in the [Sample App](https://github.com/evadne/RAPageViewController-Sample).  Page gap has also been implemented there as a freebie: the app comes with `RAPVCSViewController`, which shows a way to pad the views by overriding `-viewRectForPageRect:` and resizing the internal scroll view on view load.

## Licensing

This project is in the public domain.  You can use it and embed it in whatever application you sell, and you can use it for evil.  However, it is appreciated if you provide attribution, by linking to the project page ([https://github.com/evadne/RAPageViewController](https://github.com/evadne/RAPageViewController)) from your application.

## Credits

*	[Evadne Wu](http://twitter.com/evadne) ([Info](http://radi.ws))
