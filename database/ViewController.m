//
//  ViewController.m
//  database
//
//  Created by Feby Varghese on 7/17/12.
//  Copyright (c) 2012 febycv. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize name, address, phone;



- (void)viewDidLoad
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    self.title = @"Address Book";
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"contacts.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
		const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS(ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)";
            
            if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                UIAlertView *popup = [[UIAlertView alloc]initWithTitle:@"Failed to create table" message:@"Sorry We Couldn't Create the table" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles : nil];
                [popup show];
                [popup release];
            }
            
            sqlite3_close(contactDB);
        }
        else
        {
            UIAlertView *popup = [[UIAlertView alloc]initWithTitle:@"Failed to open/create database" message:@"Sorry We Couldn't Open the database" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles : nil];
            [popup show];
            [popup release];
        }
    }
    
    [filemgr release];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) saveData
{
    sqlite3_stmt    *statement;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO CONTACTS (name, address, phone) VALUES (\"%@\", \"%@\", \"%@\")", name.text, address.text, phone.text];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            UIAlertView *popup = [[UIAlertView alloc]initWithTitle:@"Contact added" message:@"Thank You for Your Entry" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles : nil];
            name.text = @"";
            address.text = @"";
            phone.text = @"";
            [popup show];
            [popup release];
        }
        else
        {
            UIAlertView *popup = [[UIAlertView alloc]initWithTitle:@"Failed to add contact" message:@"Sorry Your Entry is not Added" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles : nil];
            [popup show];
            [popup release];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
}

- (void) findContact
{
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *addressField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                address.text = addressField;
                
                NSString *phoneField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                phone.text = phoneField;
                UIAlertView *popup = [[UIAlertView alloc]initWithTitle:@"Match found" message:@"Your Contact is in the Database" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles : nil];
                [popup show];
                [popup release];
                
                [addressField release];
                [phoneField release];
            } else
            {
                UIAlertView *popup = [[UIAlertView alloc]initWithTitle:@"Error !!!!" message:@"No Match Found" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles : nil];
                address.text = @"";
                name.text = @"";
                phone.text = @"";
                [popup show];
                [popup release];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(contactDB);
    }
}

- (void)viewDidUnload
{
    self.name = nil;
    self.address = nil;
    self.phone = nil;
}

- (void)dealloc
{
    [name release];
    [address release];
    [phone release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
