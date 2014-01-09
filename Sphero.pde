static public interface Sphero {
	public void set_sphero (String path);
	public List<String> paired_spheros();
	public void connect ();
	public void write (byte[] packet);
	public void ping ();
	public void set_rgb (int r, int g, int b, boolean persistant);
	public int get_rgb ();
	public String get_device_name ();
	public void set_device_name (String newname);
	public String get_bluetooth_info ();
	public void sleep(int wakeup, int macro, int orbbasic);
	/**
		@param value 0 ~ 359
	*/
	public void set_heading (int value);
	public void set_stabilization (int state);
	/**
		value ca be between 0x00 and 0xFF:
        value is a multiplied with 0.784 degrees/s except for:
            0   --> 1 degrees/s
            255 --> jumps to 400 degrees/s
	*/
	public void set_rotation_rate(int val);

	/**
		value can be between 0x00 and 0xFF
	*/
	public void set_back_led_output(int value);
	/**
		speed can have value between 0x00 and 0xFF 
        heading can have value between 0 and 359 
	*/
	public void roll (int speed, int heading, int state);
	public void stop ();
}
