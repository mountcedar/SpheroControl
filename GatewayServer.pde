import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.swing.JOptionPane;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import py4j.GatewayServer;

/**
 * @brief the class to handle python data processor
 * @details
 * @author sugiyama
 */
public static class GatewayServerManager extends Thread {
	/** The logger. */
	protected static Logger logger = LoggerFactory.getLogger(GatewayServerManager.class);

	/// @todo please configure the port map of every client/server modules.
	/** The gateway port. */
	protected static int GATEWAY_PORT = 11111;

	/** The interpreter path. */
	protected String interpreterPath = "python";

	protected Map<String, String> environments = new HashMap<String, String> () {{
		put ("PATH", System.getenv("PATH"));
		put ("PYTHONPATH", ".");
	}};

	/** The exec location. */
	protected String execLocation = ".";

	/** The exec script. */
	protected String execScript = "./gateway.py";

	/** The exec script arguments */
	protected String[] execScriptArgs = new String [0];

	/** The terminate. */
	protected boolean terminate = false;

	protected boolean running = false;

	protected boolean isReady = false;

	/** The processBuilder. */
	protected ProcessBuilder processBuilder = null;

	/** The p. */
	protected Process p = null;

	/** The gateway. */
	protected GatewayServer gateway = null;

	/** The event call. */
	public static GatewayServerManager instance = null;

	/**
	 * Instantiates a new episode engine manager.
	 */
	public GatewayServerManager() {}

	/* (非 Javadoc)
	 * @see java.lang.Thread#start()
	 */
	@Override
	public synchronized void start() {
		if (running) return;

		List<String> commands = new ArrayList<String> () {{
			add(interpreterPath);
			add(execScript);
		}};
		for (String arg: execScriptArgs) commands.add(arg);
		processBuilder = new ProcessBuilder (commands.toArray(new String[0]));
		processBuilder.directory(new File(execLocation));
		Map<String, String> env = processBuilder.environment();
		for (Map.Entry entry: environments.entrySet()) env.put((String)entry.getKey(), (String)entry.getValue());
		processBuilder.redirectErrorStream(true);

		this.gateway = new py4j.GatewayServer(this);
		try {
			this.gateway.start();
		} catch (py4j.Py4JNetworkException ex) {
			if (Platform.isWindows()) {
				int result = JOptionPane.showConfirmDialog(null,
						"Unable to open connection with 'python' process. Perhaps, other 'python' process remain executed. Do you like to try to kill all other 'python' process?");
				if (result == JOptionPane.YES_OPTION) {
					try {
						Runtime.getRuntime().exec("taskkill /IM python.exe /f");
					} catch (IOException e) {
						e.printStackTrace();
						JOptionPane.showMessageDialog(null, 
							"Error occur in killing 'python' process.", "Error",
								JOptionPane.ERROR_MESSAGE);
						ex.printStackTrace();
						System.exit(-1);
					}
					//retry;
					try {
						this.gateway.start();
					} catch (py4j.Py4JNetworkException ex2) {
						ex2.printStackTrace();
						JOptionPane.showMessageDialog(null, "Error occur even after trying to kill 'python' process. Please try to manually kill 'python' process, or stop other Java program that communicate with 'python' process.", "Error",
								JOptionPane.ERROR_MESSAGE);
						ex.printStackTrace();
						System.exit(-1);
					}
				} else {
					ex.printStackTrace();
					System.exit(-1);
				}
			} else {
				JOptionPane.showMessageDialog(null, "Unable to open connection with 'python' process. Perhaps, other 'python' process remain executed.", "Error",
						JOptionPane.ERROR_MESSAGE);
				ex.printStackTrace();
				System.exit(-1);
			}
		}
		super.start();
	}

	/**
	 * Terminate.
	 */
	public void terminate() {
		try {
			if (!running) return;
			terminate = true;
			logger.info("terminating connection to GatewayServerManager");
			if (p != null) {
				p.destroy();
				p = null;
			}
			if (this.gateway != null) {
				logger.debug("terminating ... gateway shutdown");
				this.gateway.shutdown();
				this.gateway = null;
			}
			Thread.sleep(200);
			logger.debug("terminating ... waiting for a thread");
			this.join(1000);
			terminate = false;
			logger.debug("terminating ... terminated");
		} catch (Exception e) {
			logger.error("{}", e);
		}
	}

	/* (非 Javadoc)
	 * @see java.lang.Thread#run()
	 */
	public void run() {
		try {
			running = true;
			p = processBuilder.start();
			BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
			int level = 0; //remember the last information that notify debug-level
			for(String line=reader.readLine(); line!=null; line=reader.readLine()) {
				String message = new String(line.getBytes(), "UTF-8");
				if (message.startsWith("[ERROR]")) {
					level = 3;
				} else if (message.startsWith("[WARNING]")) {
					level = 2;
				} else if (message.startsWith("[INFO]")) {
					level = 1;
				} else if (message.startsWith("[DEBUG]")) {
					level = 0;
				}

				switch(level) {
				case 0:
					logger.debug(message);
					break;
				case 1:
					logger.info(message);
					break;
				case 2:
					logger.warn(message);
					break;
				case 3:
					logger.error(message);
					break;
				default:
					System.out.println(message);
					break;
				}
			}
			logger.info("disconnected to GatewayServerManager");
			running = false;
			isReady = false;
			if (!terminate) {
				JOptionPane.showMessageDialog(null, 
					"Disconneccted from GatewayServerManager before terminating. Maybe, there is unexpected error in GatewayServerManager.", 
					"Warning",
					JOptionPane.WARNING_MESSAGE);
			}
		} catch (Exception e) {
			logger.error("{}", e);
			running = false;
			isReady = false;
		}
	}


	void setInterpreterPath (String interpreterPath) {
		this.interpreterPath = interpreterPath;
	}

	void setExecLocation (String execLocation) {
		this.execLocation = execLocation;
	}

	void setExecScript (String execScript) {
		this.execScript = execScript;
	}

	void setExecScriptArgs (String[] args) {
		this.execScriptArgs = args;
	}

	void setEnvironment (String key, String value) {
		this.environments.put(key, value);
	}


	public static class Platform {
		protected static Logger logger = LoggerFactory.getLogger(Platform.class);
		protected static String OS = System.getProperty("os.name").toLowerCase();
		public static boolean isWindows() { return (OS.indexOf("win") >= 0); }
		public static boolean isMac() { return (OS.indexOf("mac") >= 0); }
		public static boolean isUnix() { return (OS.indexOf("nix") >= 0 || OS.indexOf("nux") >= 0 || OS.indexOf("aix") > 0); }
		public static boolean isSolaris() { return (OS.indexOf("sunos") >= 0); }
	}
};

