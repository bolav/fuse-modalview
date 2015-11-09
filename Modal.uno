using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Controls;
public class Modal
{
	public string Title { get; set; }
	public string Message { get; set; }
	public void ShowDialog (string dialog) {
		debug_log "Showing Dialog: " + dialog;
		if defined(iOS) {
			debug_log "iOS!";
			var alert = iOS.UIKit.UIAlertController._alertControllerWithTitleMessagePreferredStyle(
				"My alert",
				"This is an alert",
				iOS.UIKit.UIAlertControllerStyle.UIAlertControllerStyleAlert
			);
			extern "presentViewController(alert, true, null);";
		}
		else if defined(Android) {
			debug_log "Android";
		}
		else {
			debug_log "Pure UX solution";
			debug_log AppBase.Current.RootNode;
			var p = AppBase.Current.RootNode as Panel;
			debug_log p;
			debug_log p.Children;
		}
	}
}
