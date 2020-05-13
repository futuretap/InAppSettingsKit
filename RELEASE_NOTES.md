# Release Notes

## InAppSettingsKit 3.0

### Changes in `IASKSettingsDelegate`

For consistency, all delegate callbacks now include `settingsViewController` as the first argument. They no longer include the `tableView` argument. To access the table view, use the `tableView` property of the `settingsViewController`. Also, all delegate callbacks now include the `IASKSpecifier` which is more useful than a section index or index path. To access the key, you can simply use the `key` property on `IASKSpecifier`.

- `-settingsViewController:tableView:titleForHeaderForSection:` ⇒
`-settingsViewController:titleForHeaderInSection:specifier:`

- `-settingsViewController:tableView:heightForHeaderForSection:` ⇒
`-settingsViewController:heightForHeaderInSection:specifier:`

- `settingsViewController:tableView:viewForHeaderForSection:` ⇒
`settingsViewController:viewForHeaderInSection:specifier:`

- `settingsViewController:tableView:titleForFooterForSection` ⇒
`settingsViewController:titleForFooterInSection:specifier:`

- `tableView:heightForSpecifier:` ⇒
`settingsViewController:heightForSpecifier:`

- `tableView:cellForSpecifier:` ⇒
`settingsViewController:cellForSpecifier:`

- `settingsViewController:tableView:didSelectCustomViewSpecifier:` ⇒ `settingsViewController:didSelectCustomViewSpecifier:`

- `settingsViewController:buttonTappedForKey:` ⇒ `settingsViewController:buttonTappedForSpecifier:`


The following deprecated methods have been removed:

- `settingsViewController:mailComposeBodyForSpecifier:` (use  `settingsViewController:shouldPresentMailComposeViewController:forSpecifier` instead)

- `settingsViewController:viewControllerForMailComposeViewForSpecifier:`


- `settingsViewController:validationFailureForSpecifier:textField:previousValue` (use the new `settingsViewController:validateSpecifier:textField:previousValue:replacement:` instead)

- `settingsViewController:validationSuccessForSpecifier:textField:` (use the new `settingsViewController:validateSpecifier:textField:previousValue:replacement:` instead)


### Changes in settings schema

The `IASKRegex` key to validate text fields using regular expressions is no longer supported. Instead, the `settingsViewController:validateSpecifier:textField:previousValue:replacement:` delegate callback allows for much more flexibility to validate the text field in code.

### Improved Swift compatibility
All classes now use properties instead of getter methods and are nullability-annotated making it much easier to interoperate from Swift code. In fact, the sample app was rewritten in Swift – so we eat our own dog food! 🐶

### New features (see Readme)

- List Groups 
- Date Picker
- Toggles with checkmarks
- Support hiding sections
- Custom views can present a child pane on selection
- Text field validation
- Support of text content type
- Migrated the sample app to Swift
- Added extensive header documentation
