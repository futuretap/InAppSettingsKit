//
//  IASKSettingsWriterToFile.h
//  Porthole
//
//  Created by Marc-Etienne M.Léveillé on 10-11-04.
//  Copyright 2010 Edovia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IASKSettingsWriter.h"

@interface IASKSettingsWriterToFile : IASKAbstractSettingsWriter {
    NSString * _filePath;
    NSMutableDictionary * _dict;
}

- (id)initWithPath:(NSString*)path;

@end
