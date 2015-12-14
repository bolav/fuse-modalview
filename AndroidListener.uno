using Uno;
using Android.android.content;
public extern(Android) class AndroidListener : Android.java.lang.Object, Android.android.content.DialogInterfaceDLROnClickListener
{
	string _string;
	Action<string> _action;
	public AndroidListener (string s, Action<string> a) {
		_string = s;
		_action = a;
	}
    public void onClick(DialogInterface arg0, int arg1) 
    {
    	_action(_string);
    }
}
