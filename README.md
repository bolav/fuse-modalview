Modal for Fuse
==============

Library to use modal in [Fuse](http://www.fusetools.com/).

Modal dialogs are implemented using UIAlertController for iOS, and AlertDialogBuilder for Android. 
There is also a hackish fallback using UX, replacing the whole UX tree with the dialog.


```xml
<ModalJS ux:Global="Modal" />
```

```javascript
		var Modal = require('Modal');
		function click () {
			Modal.showModal(
				"This is my title",
				"This is my body. It can be very long. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer sed justo ac arcu semper egestas. Mauris eget ipsum sit amet sem vulputate congue. Nam tellus nunc, malesuada quis dignissim vitae, tincidunt quis mi.",
				["Ok", "Cancel"],
				function (s) {
					debug_log("Got callback with " + s);
				});
		}
```