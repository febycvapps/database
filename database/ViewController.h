//
//  ViewController.h
//  database
//
//  Created by Feby Varghese on 7/17/12.
//  Copyright (c) 2012 febycv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "/usr/include/sqlite3.h"

@interface ViewController : UIViewController
{
    UITextField     *name;
    UITextField *address;
    UITextField *phone;
    NSString        *databasePath;
    
    sqlite3 *contactDB;
}

@property (retain, nonatomic) IBOutlet UITextField *name;

@property (retain, nonatomic) IBOutlet UITextField *address;

@property (retain, nonatomic) IBOutlet UITextField *phone;

- (IBAction) saveData;

- (IBAction) findContact;

@end
