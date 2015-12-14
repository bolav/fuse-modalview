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
		var temp12 = new Fuse.Controls.Rectangle();
		var temp13 = new Fuse.Drawing.StaticSolidColor(float4(0f, 0f, 0f, 0.6666667f));
		temp.Alignment = Fuse.Elements.Alignment.VerticalCenter;
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
		temp2.TextAlignment = Fuse.Elements.TextAlignment.Center;
		temp3.Margin = float4(5f, 5f, 5f, 5f);
		temp3.Strokes.Add(temp4);
		temp4.Width = 1f;
		temp4.Brush = temp5;
		temp6.Content = temp7;
		temp7.Value = text;
		temp7.TextWrapping = Fuse.Elements.TextWrapping.Wrap;
		temp7.FontSize = 20f;
		temp7.TextAlignment = Fuse.Elements.TextAlignment.Center;
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

		temp12.Background = temp13;
		p.Children.Add(temp);
		p.Children.Add(temp12);
		p.HitTestMode = Fuse.Elements.HitTestMode.LocalBoundsAndChildren;
		return p;
	}

	void ButtonClickHandler (object sender, Fuse.Gestures.ClickedArgs args) {
		var button = args.Node as Button;
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
		var alert = new AlertDialogDLRBuilder(null);
		Android.java.lang.String a_title = title;
		alert.setTitle(a_title);
		Android.java.lang.String a_body = body;
		alert.setMessage(a_body);
		for (var i = 0; i < buttons.Length; i++) {
			Android.java.lang.String a_but = buttons[i] as string;
			var callback = new AndroidListener();
			debug_log "callback " + callback + "("+ buttons[i] +")";
			if (i == 0) {
				alert.setPositiveButton(a_but, callback);
			}
			else if (i == 1) {
				alert.setNeutralButton(a_but, callback);
			}
			else {
				alert.setNegativeButton(a_but, callback);
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
			parent = FindPanel(AppBase.Current.RootNode);
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
