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

        var temp = new Fuse.Controls.DockPanel();
        var temp1 = new Fuse.Controls.StackPanel();
        var temp2 = new Fuse.Controls.Text();
        var temp3 = new Fuse.Controls.Rectangle();
        var temp4 = new Fuse.Drawing.Stroke();
        var temp5 = new Fuse.Drawing.StaticSolidColor(float4(0.7294118f, 0.7294118f, 0.7294118f, 1f));
        var temp6 = new Fuse.Controls.ScrollView();
        var temp7 = new Fuse.Controls.Text();
        var temp8 = new Fuse.Controls.Grid();
        var temp11 = new Fuse.Drawing.StaticSolidColor(float4(1f, 1f, 1f, 1f));
        var temp12 = new Fuse.Drawing.StaticSolidColor(float4(0f, 0f, 0f, 0.6666667f));
        temp.Margin = float4(15f, 0f, 15f, 0f);
        temp.Padding = float4(10f, 10f, 10f, 10f);
        temp.Background = temp11;
        temp.Children.Add(temp1);
        temp.Children.Add(temp6);
        temp.Children.Add(temp8);
        global::Fuse.Controls.DockPanel.SetDock(temp1, Fuse.Layouts.Dock.Top);
        temp1.Children.Add(temp2);
        temp1.Children.Add(temp3);
        temp2.Value = title;
        temp2.TextAlignment = Fuse.Controls.TextAlignment.Center;
        temp3.Margin = float4(5f, 5f, 5f, 5f);
        temp3.Strokes.Add(temp4);
        temp4.Width = 1f;
        temp4.Brush = temp5;
        temp6.Children.Add(temp7);
        temp7.Value = text;
        temp7.TextWrapping = Fuse.Controls.TextWrapping.Wrap;
        temp7.FontSize = 20f;
        temp7.TextAlignment = Fuse.Controls.TextAlignment.Center;
        temp7.TextColor = float4(0.09019608f, 0.08627451f, 0.08627451f, 1f);
        temp7.Margin = float4(20f, 20f, 20f, 20f);
        temp8.ColumnCount = buttons.Length;
        temp8.Margin = float4(0f, 0f, 0f, 0f);
        global::Fuse.Controls.DockPanel.SetDock(temp8, Fuse.Layouts.Dock.Bottom);

		for (var i = 0; i < buttons.Length; i++) {
			var tempButton = new Fuse.Controls.Button();
			temp8.Children.Add(tempButton);
			tempButton.Text = buttons[i] as string;
			Fuse.Gestures.Clicked.AddHandler(tempButton, ButtonClickHandler);
		}

        p.Background = temp12;
        p.Children.Add(temp);

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
			if (n is Fuse.Desktop.DesktopRootViewport) {
				var a = n as Fuse.Desktop.DesktopRootViewport;
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
