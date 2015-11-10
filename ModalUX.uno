using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Controls;
public class ModalUX : Panel
{
	public string Text {
		get; set;
	}

	Modal m;
	bool shown = false;

	protected override void OnRooted()
	{
	        // base.OnRooted();
	        if (!shown) {
	        	m = new Modal(this);
	        	m.ShowDialog(Text);
	        	shown = true;	        	
	        }
	}

	protected override void OnUnrooted()
	{
	        base.OnUnrooted();
	        shown = false;
	}
}
