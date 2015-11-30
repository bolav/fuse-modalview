using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Controls;
public class Modal
{
	public Modal () {
	}
	public Modal (Panel p) {
		myModal = p;
	}

	Panel myModal;
	Panel oldRoot;
	List<Fuse.Node> old = new List<Fuse.Node>();

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
			// UIApplication._sharedApplication().Delegate.Window.RootViewController.presentViewController(alert,true,null);
			// extern "presentViewController(alert, true, null);";
		}
		else if defined(Android) {
			debug_log "Android";
		}
		else {
			debug_log "Pure UX solution";
			var p = AppBase.Current.RootNode as Panel;

			oldRoot = p;
			AppBase.Current.RootNode = myModal;
			/*
			debug_log p;
			debug_log p.Children;
			debug_log p.Children.Count;
			old.Clear();
			var e = p.Children.GetEnumerator();
			bool loop = true;
			while (loop) {
				// old.Add(e.Current);
				var m = e.Current as Node;
				if (m != null) {
					debug_log m;
					debug_log m.Name;
				}
				loop = e.MoveNext();

			}
			// p.Children.Clear();
			// p.Children.Add(myModal);
			*/
		}
	}
}
