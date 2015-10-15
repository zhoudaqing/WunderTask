//
//  PdfWebViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/23.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "PdfWebViewController.h"

@interface PdfWebViewController ()

@end

@implementation PdfWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = HTURL(self.url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.frame];
    
    [self.view addSubview:webView];
    
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

CGPDFDocumentRef GetPDFDocumentRef(NSString *filename)
{
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    size_t count;
    
    path = CFStringCreateWithCString (NULL, [filename UTF8String], kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, 0);
    
    CFRelease (path);
    document = CGPDFDocumentCreateWithURL (url);
    CFRelease(url);
    count = CGPDFDocumentGetNumberOfPages (document);
    if (count == 0) {
        printf("[%s] needs at least one page!\n", [filename UTF8String]);
        return NULL;
    } else {
        printf("[%ld] pages loaded in this PDF!\n", count);
    }
    return document;
}

void DisplayPDFPage (CGContextRef myContext, size_t pageNumber, NSString *filename)
{
    CGPDFDocumentRef document;
    CGPDFPageRef page;
    
    document = GetPDFDocumentRef (filename);
    page = CGPDFDocumentGetPage (document, pageNumber);
    CGContextDrawPDFPage (myContext, page);
    CGPDFDocumentRelease (document);
}

@end
