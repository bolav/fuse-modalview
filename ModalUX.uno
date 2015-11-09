using Uno;
using Uno.Collections;
using Fuse;
public class ModalUX : Node
{
	public string Text {
		get; set;
	}

	Modal m;
	bool shown = false;

	protected override void OnRooted()
	{
	        base.OnRooted();
	        if (!shown) {
	        	m = new Modal();
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
