/**
 *  Copyright (C) 2010-2014 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "Header.h"
#import "GDataXMLNode+PrettyFormatterExtensions.h"
#import "Util.h"

@implementation Header

+ (instancetype)defaultHeader
{
    Header *header = [[[self class] alloc] init];
    header.applicationBuildName = [Util appBuildName];
    header.applicationBuildNumber = [Util appBuildVersion];
    header.applicationName = [Util appName];
    header.applicationVersion = [Util appVersion];
    header.catrobatLanguageVersion = [Util catrobatLanguageVersion];
    header.dateTimeUpload = nil;
    header.programDescription = nil;
    header.deviceName = [Util deviceName];
    header.mediaLicense = [Util catrobatMediaLicense];
    header.platform = [Util platformName];
    header.platformVersion = [Util platformVersion];
    header.programLicense = [Util catrobatProgramLicense];
    header.programName = nil;
    header.remixOf = nil;
    header.screenHeight = @([Util screenHeight]);
    header.screenWidth = @([Util screenWidth]);
    header.screenMode = kCatrobatScreenModeStretch;
    header.url = nil;
    header.userHandle = nil;
    header.programScreenshotManuallyTaken = kCatrobatProgramScreenshotDefaultValue;
    header.tags = nil;
    return header;
}

- (GDataXMLElement*)toXML
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];

    GDataXMLElement *headerXMLElement = [GDataXMLNode elementWithName:@"header"];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"applicationBuildName"
                                         optionalStringValue:self.applicationBuildName]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"applicationBuildNumber"
                                         optionalStringValue:self.applicationBuildNumber]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"applicationName"
                                         optionalStringValue:self.applicationName]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"applicationVersion"
                                         optionalStringValue:self.applicationVersion]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"catrobatLanguageVersion"
                                         optionalStringValue:self.catrobatLanguageVersion]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"dateTimeUpload"
                                         optionalStringValue:(self.dateTimeUpload ? [dateFormatter stringFromDate:self.dateTimeUpload] : nil)]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"description"
                                         optionalStringValue:self.description]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"deviceName"
                                         optionalStringValue:self.deviceName]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"mediaLicense"
                                         optionalStringValue:self.mediaLicense]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"platform"
                                         optionalStringValue:self.platform]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"platformVersion"
                                         optionalStringValue:self.platformVersion]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"programLicense"
                                         optionalStringValue:self.programLicense]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"programName"
                                         optionalStringValue:self.programName]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"remixOf"
                                         optionalStringValue:self.remixOf]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"screenHeight"
                                         optionalStringValue:[self.screenHeight stringValue]]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"screenWidth"
                                         optionalStringValue:[self.screenWidth stringValue]]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"screenMode"
                                         optionalStringValue:self.screenMode]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"tags"
                                         optionalStringValue:self.tags]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"url"
                                         optionalStringValue:self.url]];
    [headerXMLElement addChild:[GDataXMLNode elementWithName:@"userHandle"
                                         optionalStringValue:self.userHandle]];
    return headerXMLElement;
}

@end
