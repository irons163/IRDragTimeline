![Build Status](https://img.shields.io/badge/build-%20passing%20-brightgreen.svg)
![Platform](https://img.shields.io/badge/Platform-%20iOS%20-blue.svg)

# IRDragTimeline

- IRDragTimeline is a powerful drag-and-drop expandable tableview for iOS.

## Features
- Expandable tableview with nested.
- Able to drag-and-drop.
- Has a demo.

## Install
### Git
- Git clone this project.
- Copy `Class` amd `Utility` folders into your own project.
- See how to use it in `README` or `ViewController.m`.

### Cocoapods
- Not support yet.

## Usage

### Basic
- Set Branch
``` objective-c
#import "TimelineManager.h"

...

Branch *branch = [[TimelineManager sharedInstance] branchFromClientJourneyData:_clientJourneyData];
branch.tableView = self.timelineTableView;
branch.delegate = self;

[self.timelineTableView reloadDataWithCompletion:^{
    [self.delegate didUpdate:nil];
}];
```

- Set Delegate
``` objective-c
#import "TimelineManager.h"

...

@interface MonitorClientsDetailTimelineTableViewCell ()<BranchDelegate>

...

- (void)willUpdate:(NSNumber *)pos {
    [self.delegate willUpdate:pos];
}

- (void)didUpdate:(NSNumber *)pos {
    [self layoutIfNeeded];
    
    [self.delegate didUpdate:pos];
}

```

### Advance
- Please see the demo in ViewController.

## Screenshots
![Demo](./ScreenShots/demo1.png)
![Demo](./ScreenShots/demo2.png)

