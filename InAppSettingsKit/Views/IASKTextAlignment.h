//
//  IASKTextAlignment.h
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2012:
//  Five Lakes Studio, Inc. http://www.fivelakesstudio.com
//  All rights reserved.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//


// The IOS5 text alignment constants where deprecated in IOS 6 (iPhone 5).  These
// constants allow us to compile without warnings in IOS 6 projects
//
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0)
    #define IOS_UITextAlignmentLeft   NSTextAlignmentLeft
    #define IOS_UITextAlignmentCenter NSTextAlignmentCenter
    #define IOS_UITextAlignmentRight  NSTextAlignmentRight

    #define IOS_UILineBreakModeWordWrap  NSLineBreakByWordWrapping
#else
    #define IOS_UITextAlignmentLeft   UITextAlignmentLeft
    #define IOS_UITextAlignmentCenter UITextAlignmentCenter
    #define IOS_UITextAlignmentRight  UITextAlignmentRight

    #define IOS_UILineBreakModeWordWrap  UILineBreakModeWordWrap
#endif
