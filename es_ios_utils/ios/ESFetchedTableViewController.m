#if IS_IOS

#import "ESFetchedTableViewController.h"

@implementation ESFetchedTableViewController

@synthesize fetchedResultsController, managedObjectContext, sectionNameKeyPath, doOnError, entityName, sortDescriptors, cellStyle;

-(id)init
{
    self.doOnError = ^(NSError *e){
        [e log];
        abort();
    };
    self.cellStyle = UITableViewCellStyleDefault;
    return self;
}

-(id)initWithNibName:(NSString*)name bundle:(NSBundle*)b
{
    [self init];
    return [super initWithNibName:name bundle:b];
}

-(id)initWithCoder:(NSCoder*)coder
{
    [self init];
    return [super initWithCoder:coder];
}

-(id)objectAtIndexPath:(NSIndexPath*)i
{
    return [self.fetchedResultsController objectAtIndexPath:i];
}

-(NSIndexPath*)indexPathForObject:(id)o
{
    return [self.fetchedResultsController indexPathForObject:o];
}

-(void)selectObject:(id)o scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    [self.tableView selectRowAtIndexPath:[self indexPathForObject:o] animated:YES scrollPosition:scrollPosition];
}

-(void)deselectObject:(id)o
{
    [self.tableView deselectRowAtIndexPath:[self indexPathForObject:o] animated:YES];
}

-(void)deselectAll
{
    [self.tableView deselectAll];
}

#pragma mark - Implement

static NSString *kESFetchedTableViewControllerCell = @"ESFetchedTableViewControllerCell";

-(UITableViewCell*)createCell
{
    return  [[[UITableViewCell alloc] initWithStyle:self.cellStyle
                                    reuseIdentifier:kESFetchedTableViewControllerCell] autorelease];
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    $must_override;
}

-(void)didSelectObject:(id)o { }
-(void)didDeselectObject:(id)o { }

#pragma mark - Table Controller, Datasource, and Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{    
    return self.fetchedResultsController.sections.count;
}

-(int)tableView:(UITableView*)t numberOfRowsInSection:(int)s
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:s];
    return sectionInfo.numberOfObjects;
}

-(NSString*)tableView:(UITableView *)t titleForHeaderInSection:(NSInteger)s
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:s];
    return sectionInfo.name;
}

-(UITableViewCell*)tableView:(UITableView*)t cellForRowAtIndexPath:(NSIndexPath*)i
{    
    UITableViewCell *c = [t dequeueReusableCellWithIdentifier:kESFetchedTableViewControllerCell];
    if (!c)
        c = [self createCell];
    
    [self configureCell:c atIndexPath:i];
    
    return c;
}

-(void)tableView:(UITableView*)t didSelectRowAtIndexPath:(NSIndexPath*)i
{
    [self didSelectObject:[self objectAtIndexPath:i]];
}

-(void)tableView:(UITableView*)t didDeselectRowAtIndexPath:(NSIndexPath*)i
{
    [self didDeselectObject:[self objectAtIndexPath:i]];
}

-(void)configureFetchRequest:(NSFetchRequest*)fetchRequest
{
    //optional
}

-(void)configureFetchRequestController:(NSFetchedResultsController*)controller
{
    //optional
}

-(void)tableView:(UITableView*)t commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)i
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [managedObjectContext deleteObject:[self objectAtIndexPath:i]];
        [managedObjectContext saveAndDoOnError:self.doOnError];
    }   
}


#pragma mark - Fetched results controller

-(NSFetchedResultsController*)fetchedResultsController
{
    assert(managedObjectContext);

    if (fetchedResultsController)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    assert(self.entityName);
    fetchRequest.entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:managedObjectContext];
    assert(fetchRequest.entity);
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.sortDescriptors = self.sortDescriptors;
    [self configureFetchRequest:fetchRequest];
    self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath cacheName:nil] autorelease];
    self.fetchedResultsController.delegate = self;
    
    [self configureFetchRequestController:self.fetchedResultsController];
    [self.fetchedResultsController performFetchAndDoOnError:self.doOnError];
    
    return fetchedResultsController;
}

#pragma mark - Fetched results controller delegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
          atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
     newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowAtIndexPath:newIndexPath withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowAtIndexPath:newIndexPath withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark -

-(void)dealloc
{
    self.fetchedResultsController = nil;
    self.managedObjectContext = nil;
    
    [super dealloc];
}

@end

#endif /*IS_IOS*/