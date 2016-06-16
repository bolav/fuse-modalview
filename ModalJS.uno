using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Reactive;
using Fuse.Scripting;
using Fuse.Controls;
using Uno.Compiler.ExportTargetInterop;
using Android.android.app;

[TargetSpecificImplementation]
public class ModalJS : NativeModule
{
	public ModalJS () {
		AddMember(new NativeFunction("showModal", (NativeCallback)ShowModal));
	}

	Panel myPanel;
	Panel parent;
	Panel UXModal(string title, string text, Fuse.Scripting.Array buttons) {
		var p = new Fuse.Controls.Panel();
		return p;
	}

	void ButtonClickHandler (object sender, Fuse.Gestures.ClickedArgs args) {
		var button = args.Visual as Button;
		running = false;
		UpdateManager.PostAction(RemoveModalUX);
		Context.Dispatcher.Invoke(new InvokeEnclosure(callback, button.Text).InvokeCallback);
	}

	class InvokeEnclosure {
		public InvokeEnclosure (Fuse.Scripting.Function func, string cbtext) {
			callback = func;
			callback_text = cbtext;
		}
		Fuse.Scripting.Function callback;
		string callback_text;
		public void InvokeCallback () {
			callback.Call(callback_text);
		}
	}

	List<Node> ChildrenBackup;
	void AddModalUX() {
		var c = parent.Children;
		ChildrenBackup = new List<Node>();
		for (int i=0; i< parent.Children.Count; i++) {
			ChildrenBackup.Add(c[i]);
		}
		parent.Children.Clear();
		parent.Children.Add(myPanel);
	}

	void RemoveModalUX() {
		parent.Children.Clear();
		for (int i=0; i< ChildrenBackup.Count; i++) {
			parent.Children.Add(ChildrenBackup[i]);
		}

	}

	extern(iOS)
	void iOSClickHandler (int id) {
		running = false;
		var s = buttons[id] as string;
		Context.Dispatcher.Invoke(new InvokeEnclosure(callback, s).InvokeCallback);
	}

	extern(Android)
	void AndroidClickHandler (string s) {
		running = false;
		Context.Dispatcher.Invoke(new InvokeEnclosure(callback, s).InvokeCallback);
	}

	Context Context;
	Fuse.Scripting.Function callback;
	bool running = false;
	Fuse.Scripting.Array buttons;
	string title;
	string body;

	[TargetSpecificImplementation]
	extern(iOS)
	public void ShowImpl(iOS.UIKit.UIViewController controller, ObjC.ID alert, string[] buttons);

	extern(iOS)
	public void ShowModaliOS() {
		if (title == "HACKETIHACK") {
			iOSClickHandler(-1);
		}
		var alert = iOS.UIKit.UIAlertController._alertControllerWithTitleMessagePreferredStyle(
			title,
			body,
			iOS.UIKit.UIAlertControllerStyle.UIAlertControllerStyleAlert
		);

		var s_buttons = new string[buttons.Length];
		for (var i = 0; i < buttons.Length; i++) {
			s_buttons[i] = buttons[i] as string;
		}

		// var alert_uivc = new iOS.UIKit.UIAlertController(alert);
		//var action = new iOS.UIKit.UIAlertAction();
		// action.Title = "OK";

		var uivc = iOS.UIKit.UIApplication._sharedApplication().KeyWindow.RootViewController;
		ShowImpl(uivc, alert, s_buttons);
		// uivc.presentModalViewControllerAnimated(alert_uivc, false);
	}

	extern(Android)
	public void ShowModalAndroid() {
		// Might want to throw error if more than 3 buttons
		var ctx = Android.android.app.Activity.GetAppActivity();
		var alert = new AlertDialogDLRBuilder(ctx);
		Android.java.lang.String a_title = title;
		alert.setTitle(a_title);
		alert.setCancelable(false);
		Android.java.lang.String a_body = body;
		alert.setMessage(a_body);

		for (var i = 0; i < buttons.Length; i++) {
			var s = buttons[i] as string;
			Android.java.lang.String a_but = s;
			var clickhandler = new AndroidListener(s, AndroidClickHandler);
			if (i == 0) {
				alert.setNegativeButton(a_but, clickhandler);
			}
			else if ((i == 1)&&(buttons.Length>2)) {
				alert.setNeutralButton(a_but, clickhandler);
			}
			else {
				alert.setPositiveButton(a_but, clickhandler);
			}
		}
		alert.show();
	}

	object ShowModal (Context c, object[] args) {
		if (running) return null;
		running = true;
		title = args[0] as string;
		body = args[1] as string;
		buttons = args[2] as Fuse.Scripting.Array;
		callback = args[3] as Fuse.Scripting.Function;
		Context = c;

		Uno.Diagnostics.Debug.Alert(body);
		if defined(iOS) {
			UpdateManager.PostAction(ShowModaliOS);
			return null;
		}
		else if defined(Android) {
			UpdateManager.PostAction(ShowModalAndroid);
			return null;
		}
		else {
			parent = FindPanel(AppBase.Current.RootViewport);
			myPanel = UXModal(title, body, buttons);
			UpdateManager.PostAction(AddModalUX);
			return null;
		}

	}

	Panel FindPanel (Node n) {
		debug_log "FindPanel " + n;
		if defined(CIL) {
			if (n is Outracks.Simulator.FakeApp) {
				var a = n as Outracks.Simulator.FakeApp;
				var c = a.Children[1];
				debug_log a.Children.Count;
				return FindPanel(c);
			}
		}
		if (n is Fuse.Controls.Panel) {
			var p = n as Fuse.Controls.Panel;
			return p;
		}
		return null;
	}
}
