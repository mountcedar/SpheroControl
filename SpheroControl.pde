import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

Logger rootLogger = LoggerFactory.getLogger("root");

static public class GatewayServerImpl extends GatewayServerManager {
	static Logger logger = LoggerFactory.getLogger(GatewayServerImpl.class);
	protected Sphero sphero = null;

	public GatewayServerImpl() { 
		super(); 
	}

	public void register (Sphero sphero) {
		this.sphero = sphero;
	}

};

GatewayServerImpl manager = null;

void setup () {
	try {
		size(640, 480);
		frameRate(10);

		manager = new GatewayServerImpl();
		manager.setExecLocation(sketchPath + "/engine");
		manager.setExecScript("./gateway.py");
		manager.start();

		while (manager.sphero == null) Thread.sleep(100);
		Sphero s = manager.sphero;

		// println ("paired_spheros: ");
		// List<String> spheros = s.paired_spheros();
		// for (String sname: spheros) println ("\t" + sname);
		println ("gonna ping ...");
		s.ping();
		println ("rgb info: " + Integer.toString(s.get_rgb()));
		println ("setting spheros name as hoge ...");
		s.set_device_name("hoge");
		print ("device name: " + s.get_device_name());
		println ("bluetooth info: " + s.get_bluetooth_info());
		println ("setting head as 30");
		s.set_heading(30);
		println ("set_stabilization as 1");
		s.set_stabilization(1);
		println ("set rotation rate as 0x20");
		s.set_rotation_rate(0x20);
		println ("set back led output as 0x20");
		s.set_back_led_output(0x20);

	} catch (Exception e) {
		rootLogger.error ("Error: {}", e);
	}
}

void draw () {
	try {
		if (manager.sphero != null) {
			manager.sphero.set_rgb((int)random(0,255), (int)random(0, 255), (int)random(0, 255), false);
		}
	} catch (Exception e) {
		rootLogger.error ("Error: {}", e);
	}
}

void dispose() {
	manager.terminate();
	super.dispose();
}