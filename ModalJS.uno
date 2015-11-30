using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Reactive;
using Fuse.Scripting;
using Fuse.Controls;
using Uno.Compiler.ExportTargetInterop;

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
		UpdateManager.PostAction(RemoveModal);
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
	void AddModal() {
		var c = parent.Children;
		ChildrenBackup = new List<Node>();
		for (int i=0; i< parent.Children.Count; i++) {
			ChildrenBackup.Add(c[i]);
		}
		parent.Children.Clear();
		parent.Children.Add(myPanel);
	}

	void RemoveModal() {
		parent.Children.Clear();
		for (int i=0; i< ChildrenBackup.Count; i++) {
			parent.Children.Add(ChildrenBackup[i]);
		}

	}

	Context Context;
	Fuse.Scripting.Function callback;
	Fuse.Scripting.Array buttons;

	[TargetSpecificImplementation]
	extern(iOS)
	public void ShowImpl(iOS.UIKit.UIViewController controller, ObjC.ID alert, string[] buttons);

	extern(iOS)
	public void ShowModaliOS() {
		debug_log "iOS!";
		var alert = iOS.UIKit.UIAlertController._alertControllerWithTitleMessagePreferredStyle(
			"My alert",
			"This is an alert",
			iOS.UIKit.UIAlertControllerStyle.UIAlertControllerStyleAlert
		);

		var s_buttons = new string[buttons.Length];
		for (var i = 0; i < buttons.Length; i++) {
			s_buttons[i] = buttons[i] as string;
			debug_log buttons[i] as string;
			var s = buttons[i] as string;
			debug_log s;
		}

		var n_alert = iOS.UIKit.UIAlertController._alertControllerWithTitleMessagePreferredStyle(
			s_buttons[0],
			"This is an alert",
			iOS.UIKit.UIAlertControllerStyle.UIAlertControllerStyleAlert
		);

		// var alert_uivc = new iOS.UIKit.UIAlertController(alert);
		//var action = new iOS.UIKit.UIAlertAction();
		// action.Title = "OK";

		var uivc = iOS.UIKit.UIApplication._sharedApplication().KeyWindow.RootViewController;
		ShowImpl(uivc, alert, s_buttons);
		// uivc.presentModalViewControllerAnimated(alert_uivc, false);
	}

	object ShowModal (Context c, object[] args) {
		if defined(iOS) {
			UpdateManager.PostAction(ShowModaliOS);
			return null;
		}
		else {
			parent = FindPanel(AppBase.Current.RootNode);
			var title = args[0] as string;
			var body = args[1] as string;
			buttons = args[2] as Fuse.Scripting.Array;
			callback = args[3] as Fuse.Scripting.Function;
			Context = c;
			myPanel = UXModal(title, body, buttons);
			UpdateManager.PostAction(AddModal);
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
