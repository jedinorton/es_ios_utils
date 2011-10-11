#if IS_IOS

#import <UIKit/UIKit.h>

// All available actions(selector, block, popover) will be run upon selection unless the associated popover is already open, in which case the popover will close and no actions will be run.
@interface ESBarButtonItem : UIBarButtonItem
  +(ESBarButtonItem*)barButtonItemWithTitle:(NSString*)title action:(void(^)(void))blockAction;
  +(ESBarButtonItem*)barButtonItemToEditTable:(UITableView*)t;

  @property(nonatomic, copy) void(^blockAction)(void);
  @property(nonatomic, retain) IBOutlet UIViewController* viewControllerForPopover;

  -(IBAction)presentPopover;
  -(IBAction)dismissPopover;
@end

#endif /*IS_IOS*/