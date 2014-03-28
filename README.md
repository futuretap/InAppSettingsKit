InAppSettingsKit
================

InAppSettingsKit is an open source solution to to easily add in-app settings to your iPhone apps. It uses a hybrid approach by maintaining the Settings.app pane. So the user has the choice where to change the settings. More details about the history of this development on the [FutureTap Blog](http://www.futuretap.com/blog/inappsettingskit) and the [Edovia Blog](http://www.edovia.com/blog/inappsettingskit).

<a href="https://flattr.com/thing/799297/futuretapInAppSettingsKit-on-GitHub" target="_blank">
<img src="http://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0" /></a>


How does it work?
=================

To support traditional Settings.app panes, the app must include a `Settings.bundle` with at least a `Root.plist` to specify the connection of settings UI elements with `NSUserDefaults` keys. InAppSettingsKit basically just uses the same Settings.bundle to do its work. This means there's no additional work when you want to include a new settings parameter. It just has to be added to the Settings.bundle and it will appear both in-app and in Settings.app. All settings types like text fields, sliders, toggle elements, child views etc. are supported.


The License
===========

We released the code under the liberal BSD license in order to make it possible to include it in every project, be it a free or paid app. The only thing we ask for is giving the [original developers](http://www.inappsettingskit.com/about) some credit. The easiest way to include credits is by leaving the "Powered by InAppSettingsKit" notice in the code. If you decide to remove this notice, a noticeable mention on the App Store description page or homepage is fine, too. To gain some exposure for your app we suggest [adding your app](http://www.inappsettingskit.com/apps) to our list.


How to include it?
==================

The source code is available on [github](http://github.com/futuretap/InAppSettingsKit). Basically you have 2 options of including InAppSettingsKit:

1) you copy the `InAppSettingsKit` subfolder into your project and drag the files right into your application. InAppSettingsKitSampleApp.xcodeproj demonstrates this scenario. If your project is compiled without ARC, you'll need to enable it for the IASK files. You can do so by adding `-fobjc-arc` in the "Compile Sources" phase. You can select all the relevant files at once with shift-click and then double-click in the Compiler Flags column to enter the text.

2) you can use the static library project to include InAppSettingsKit. To see an example on how to do it, open InAppSettingsKit.xcworkspace. It includes the sample application that uses the static library as well as the static library project itself. To include the static library project there are only a few steps necessary (the guys at [HockeyApp](http://hockeyapp.net) have a [nice tutorial](http://support.hockeyapp.net/kb/client-integration/integrate-hockeyapp-on-ios-as-a-subproject-advanced-usage) about using static libraries, just ignore the parts about the resource bundle):

* add the InAppSettingsKit.xcodeproject into your application's workspace
* add libInAppSettingsKit.a to your application's libraries by opening the Build-Phases pane of the main application and adding it in `Link Binary with Libraries`
* use IASK by importing it via #import "InAppSettingsKit/..."
* for Archive builds there's a minor annoyance: To make those work, you'll need to add `$(OBJROOT)/UninstalledProducts/include` to the `HEADER_SEARCH_PATHS`


Then you can display the InAppSettingsKit view controller using a navigation push, as a modal view controller or in a separate tab of a TabBar based application. The sample app demonstrates all three ways to integrate InAppSettingsKit. 

Depending on your project it might be needed to make some changes in the startup code of your app. Your app has to be able to reconfigure itself at runtime if the settings are changed by the user. This could be done in a `-reconfigure` method that is being called from `-applicationDidFinishLaunching` as well as in the delegate method `-settingsViewControllerDidEnd:` of `IASKAppSettingsViewController`.

You may need to make two changes to your project to get it to compile: 1) Add `MessageUI.framework` and 2) enable ARC for the IASK files. Both changes can be made by finding your target and navigating to the Build Phases tab. 

`MessageUI.framework` is needed for `MFMailComposeViewController` and can be added in the "Link Binary With Libraries" Section. Use the + icon.

To enable ARC select all IASK* source files in the "Compile Sources" section, press Enter, insert `-fobjc-arc` and then "Done".



iCloud sync
===========
To sync your `NSUserDefaults` with iCloud, there's another project called [FTiCloudSync](https://github.com/futuretap/FTiCloudSync) which is implemented as a category on `NSUserDefaults`: All write and remove requests are automatically forwarded to iCloud and all updates from iCloud are automatically stored in `NSUserDefaults`. InAppSettingsKit automatically updates the UI if the standard `NSUserDefaults` based store is used.



Goodies
=======
The intention of InAppSettingsKit was to create a 100% imitation of the Settings.app behavior. However, we added some bonus features for extra flexibility.


Custom inApp plists
---------------------------
Since iOS 4 Settings plists can be device-dependent: `Root~ipad.plist` will be used on iPad and `Root~iphone.plist` on iPhone. If not existent, `Root.plist` will be used. InAppSettingsKit adds the possibility to override those standard files by using `.inApp.plist` instead of `.plist`. Alternatively, you can create a totally separate bundle named `InAppSettings.bundle` instead of the usual `Settings.bundle`. The latter approach is useful if you want to suppress the settings in Settings.app.

In summary, the plists are searched in this order:

- InAppSettings.bundle/FILE~DEVICE.inApp.plist
- InAppSettings.bundle/FILE.inApp.plist
- InAppSettings.bundle/FILE~DEVICE.plist
- InAppSettings.bundle/FILE.plist
- Settings.bundle/FILE~DEVICE.inApp.plist
- Settings.bundle/FILE.inApp.plist
- Settings.bundle/FILE~DEVICE.plist
- Settings.bundle/FILE.plist

Different in-app settings are useful in a variety of situations. For example, [Where To?](http://www.futuretap.com/whereto) uses this mechanism to change the wording of "At next start" (for resetting confirmation dialogs) to be appropriate if the app is already running.


IASKOpenURLSpecifier
--------------------
InAppSettingsKit adds a new element that allows to open a specified URL using an external application (i.e. Safari or Mail). See the sample `Root.inApp.plist` for details.


IASKMailComposeSpecifier
------------------------
The custom `IASKMailComposeSpecifier` element allows to send mail from within the app by opening a mail compose view. You can set the following (optional) parameters using the settings plist: `IASKMailComposeToRecipents`, `IASKMailComposeCcRecipents`, `IASKMailComposeBccRecipents`, `IASKMailComposeSubject`, `IASKMailComposeBody`, `IASKMailComposeBodyIsHTML`. Optionally, you can implement

    - (NSString*)settingsViewController:(id<IASKViewController>)settingsViewController mailComposeBodyForSpecifier:(IASKSpecifier*)specifier;

in your delegate to pre-fill the body with dynamic content (great to add device-specific data in support mails for example). An alert is displayed if Email is not configured on the device. `IASKSpecifier` is the internal model object defining a single settings cell. Important IASKSpecifier properties:

- `key`: corresponds to the `Key` in the Settings plist
- `title`: the localized title of settings key
- `type`: corresponds to the `Type` in the Settings plist
- `defaultValue`: corresponds to the `DefaultValue` in the Settings plist


IASKButtonSpecifier
-------------------
InAppSettingsKit adds a `IASKButtonSpecifier` element that allows to call a custom action. Just add the following delegate method:

    - (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier;

The sender is always an instance of `IASKAppSettingsViewController`, a `UIViewController` subclass. So you can access its view property (might be handy to display an action sheet) or push another view controller. Another nifty feature is that the title of IASK buttons can be overriden by the (localizable) value from `NSUserDefaults` (or any other settings store - see below). This comes in handy for toggle buttons (e.g. Login/Logout). See the sample app for details.

By default, Buttons are aligned centered except if an image is specified (default: left-aligned). The default alignment may be overridden.


FooterText
----------
The FooterText key for Group elements is available in system settings since iOS 4. It is supported in InAppSettingsKit as well. On top of that, we support this key for Multi Value elements as well. The footer text is displayed below the table of multi value options.


IASKCustomViewSpecifier
-----------------------
You can specify your own `UITableViewCell` within InAppSettingsKit by using the type `IASKCustomViewSpecifier`. A mandatory field in this case is the `Key` attribute. Also, you have to support the `IASKSettingsDelegate` protocol and implement these methods:

    - (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier;
    - (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier;

Both methods are called for all your `IASKCustomViewSpecifier` entries. To differentiate them, you can access the `Key` attribute using `specifier.key`. In the first method you return the height of the cell, in the second method the cell itself. You should use reusable `UITableViewCell` objects as usual in table view programming. There's an example in the Demo app.
Optionally you can implement

    - (void)settingsViewController:(IASKAppSettingsViewController*)sender tableView:(UITableView *)tableView didSelectCustomViewSpecifier:(IASKSpecifier*)specifier;

to catch tap events for your custom view.



Custom Group Header Views
-------------------------
You can define custom headers for `PSGroupSpecifier` segments by adding a `Key` attribute and implementing these methods in your `IASKSettingsDelegate`:

    - (CGFloat)settingsViewController:(id<IASKViewController>)settingsViewController tableView:(UITableView*)tableView heightForHeaderForSection:(NSInteger)section;
    - (UIView*)settingsViewController:(id<IASKViewController>)settingsViewController tableView:(UITableView *)tableView viewForHeaderForSection:(NSString*)key;

The behaviour is similar to the custom cells except that the methods get the key directly as a string, not via a `IASKSpecifier` object. (The reason being that custom group header views are meant to be static.) Again, check the example in the demo app.


Custom ViewControllers
----------------------
For child pane elements (`PSChildPaneSpecifier`), Apple requires a `file` key that specifies the child plist. InAppSettingsKit allow to alternatively specify `IASKViewControllerClass` and `IASKViewControllerSelector`. In this case, the child pane is displayed by instantiating a UIViewController subclass of the specified class and initializing it using the init method specified in the `IASKViewControllerSelector`. The selector must have two arguments: an `NSString` argument for the file name in the Settings bundle and the `IASKSpecifier`. The custom view controller is then pushed onto the navigation stack. See the sample app for more details.
##### Using Custom ViewControllers from StoryBoard
Alternatively specify `IASKViewControllerStoryBoardId` to initiate a viewcontroller from [main storyboard](https://developer.apple.com/library/ios/documentation/general/conceptual/Devpedia-CocoaApp/Storyboard.html/).
Specifiy `IASKViewControllerStoryBoardFile` to use a story board other than MainStoryboard file.


Text alignment
--------------
For some element types, a `IASKTextAlignment` attribute may be added with the following values to override the default alignment:

- `IASKUITextAlignmentLeft` (Buttons, TitleValue, MultiValue, OpenURL, TextField)
- `IASKUITextAlignmentCenter` (Buttons, OpenURL)
- `IASKUITextAlignmentRight` (Buttons, TitleValue, MultiValue, OpenURL, TextField)


Variable font size
------------------
By default, the labels in the settings table are displayed in a variable font size, especially handy to squeeze-in long localizations (beware: this might break the look in Settings.app if labels are too long!).
To disable this behavior, add a `IASKAdjustsFontSizeToFitWidth` Boolean attribute with value `NO`.


Icons
-----
All element types (except sliders which already have a `MinimumValueImage`) support an icon image on the left side of the cell. You can specify the image name in an optional `IASKCellImage` attribute. The ".png" or "@2x.png" suffix is automatically appended and will be searched in the project. Optionally, you can add an image with suffix "Highlighted.png" or "Highlighted@2x.png" to the project and it will be automatically used as a highlight image when the cell is selected (for Buttons and ChildPanes).


Settings Storage
----------------
The default behaviour of IASK is to store the settings in `[NSUserDefaults standardUserDefaults]`. However, it is possible to change this behavior by setting the `settingsStore` property on an `IASKAppSettingsViewController`. IASK comes with two store implementations: `IASKSettingsStoreUserDefaults` (the default one) and `IASKSettingsStoreFile`, which read and write the settings in a file of the path you choose. If you need something more specific, you can also choose to create your own store. The easiest way to create your own store is to create a subclass of `IASKAbstractSettingsStore`. Only 3 methods are required to override. See `IASKSettingsStore.{h,m}` for more details.


Notifications
-------------
There's a `kIASKAppSettingChanged` notification that is sent for every changed settings key. The `object` of the notification is the userDefaults key (NSString*). The `userInfo` dictionary contains the new value of the key.


Dynamic cell hiding
-------------------
Sometimes, options depend on each other. For instance, you might want to have an "Auto Connect" switch, and let the user set username and password if enabled. To react on changes of a specific setting, use the `kIASKAppSettingChanged` notification explained above.

To hide a set of cells use:

    - (void)[IASKAppSettingsViewController setHiddenKeys:(NSSet*)hiddenKeys animated:(BOOL)animated];

or the non-animated version:

	@property (nonatomic, retain) NSSet *hiddenKeys;

See the sample app for more details. Note that InAppSettingsKit uses Settings schema, not TableView semantics: If you want to hide a group of cells, you have to include the Group entry as well as the member entries.


Subclassing notes
-----------------
If you'd like to customize the appearance of InAppSettingsKit, you might want to subclass `IASKAppSettingsViewController` and override some `UITableViewDataSource` or `UITableViewDelegate` methods.


More information
----------------
In the [Dr. Touch podcast](http://www.drobnik.com/touch/2010/01/dr-touch-010-a-new-decade/) and the [MDN Show Episode 027](http://itunes.apple.com/us/podcast/the-mdn-show/id318584787) [Ortwin Gentz](http://twitter.com/ortwingentz) talks about InAppSettingsKit.
