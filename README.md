Modal for Fuse [![Build Status](https://travis-ci.org/bolav/fuse-modalview.svg?branch=master)](https://travis-ci.org/bolav/fuse-modalview) ![Fuse Version](https://fuse-version.herokuapp.com/?repo=https://github.com/bolav/fuse-modalview)
==============

Library to use modal in [Fuse](http://www.fusetools.com/).

Modal dialogs are implemented using UIAlertController for iOS, and AlertDialogBuilder for Android. 
There is also a hackish fallback using UX, replacing the whole UX tree with the dialog.

## Installation

Using [fusepm](https://github.com/bolav/fusepm)

    $ fusepm install https://github.com/bolav/fuse-modalview


## Usage

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

## Layout Control

Use the following commands for text layout

	\n  for a new line

(Feel free to make a Pull Request if can add other commands)