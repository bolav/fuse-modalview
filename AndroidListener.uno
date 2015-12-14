using Android.android.content;
public extern(Android) class AndroidListener : Android.java.lang.Object, Android.android.content.DialogInterfaceDLROnClickListener
{
    public void onClick(DialogInterface arg0, int arg1) 
    {
    	debug_log "onClick";
    }
}
