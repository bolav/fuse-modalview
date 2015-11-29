using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Reactive;
using Fuse.Scripting;
using Fuse.Controls;
public class ModalJS : NativeModule
{
	public ModalJS () {
		AddMember(new NativeFunction("showModal", (NativeCallback)ShowModal));
	}

	Panel myPanel;
	Panel parent;
	Panel UXModal(string title, string text) {
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
		var temp9 = new Fuse.Controls.Button();
		var temp10 = new Fuse.Controls.Button();
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
		temp8.ColumnCount = 2;
		temp8.Margin = float4(0f, 0f, 0f, 0f);
		global::Fuse.Controls.DockPanel.SetDock(temp8, Fuse.Layouts.Dock.Bottom);
		temp8.Children.Add(temp9);
		temp8.Children.Add(temp10);
		temp9.Text = "B1";
		temp10.Text = "B2";
		temp12.Background = temp13;
		p.Children.Add(temp);
		p.Children.Add(temp12);
		return p;
	}

	void AddModal() {
		debug_log "ADDING!! " + myPanel +  " to " + parent;
		parent.Children.Add(myPanel);
	}

	object ShowModal (Context c, object[] args) {
		debug_log "ShowModal";
		parent = FindPanel(AppBase.Current.RootNode);
		myPanel = UXModal("Tittel", "Tekst");
		UpdateManager.PostAction(AddModal);
		return null;
	}

	Panel FindPanel (Node n) {
		debug_log "FindPanel " + n;
		if (n is Outracks.Simulator.FakeApp) {
			var a = n as Outracks.Simulator.FakeApp;
			var c = a.Children[1];
			debug_log a.Children.Count;
			return FindPanel(c);
		}
		if (n is Fuse.Controls.Panel) {
			var p = n as Fuse.Controls.Panel;
			return p;
		}
		return null;
	}
}
