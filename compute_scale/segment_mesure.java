// Importation des paquets n�cessaires. Le plugin n'est pas lui-m�me un paquet (pas de mot-cl� package)
import ij.*; 							// pour classes ImagePlus et IJ
import ij.plugin.filter.PlugInFilter; 	// pour interface PlugInFilter
import ij.plugin.*;
import ij.gui.Toolbar;
import java.awt.event.*;
import java.util.HashMap;
import ij.ImagePlus;
import ij.io.FileInfo;
import ij.io.OpenDialog;
import ij.process.*; 					// pour classe ImageProcessor
import ij.gui.*;						// pour classe GenericDialog et Newimage
import java.io.*;
import java.lang.System;

public class segment_mesure implements PlugIn, ImageListener, IJEventListener{
	ImagePlus Currentimp;
	//path to scale file = current path of this script + path to scale
	String pathToScaleFile;//=IJ.getDirectory("current")+"SCALE/echelle_computed_horizontal.txt";
	HashMap<String, Double> scale;
	/*public int setup(String arg, ImagePlus imp) {
		this.imp = imp;

		return DOES_RGB;
	}*/

	public void run( String arg){
		//open Dialog to get user scale file
		OpenDialog od = new OpenDialog("Choose a file containing 3x3 Homography Matrix");
		String dir = od.getDirectory();
		String fileName = od.getFileName();
		//directory+filename of scale file used
		String pathToScaleFile = dir + fileName;
		IJ.log(pathToScaleFile);
		//check if file not null
		if (fileName != null){
			scale = new HashMap<String, Double>();
			try{
				InputStream flux=new FileInputStream(pathToScaleFile);
				InputStreamReader lecture=new InputStreamReader(flux);
				BufferedReader buff=new BufferedReader(lecture);
				String ligne;
				while ((ligne=buff.readLine())!=null){
					String[] strings = ligne.split(" ");
					scale.put(strings[0], Double.parseDouble(strings[1]));
				}
				buff.close();
			}
			catch (Exception e){
				IJ.log("error");
			}
			//listener
			ImagePlus.addImageListener(this);
			IJ.addEventListener(this);
			//info start log
			IJ.log("EventListener started");
			IJ.log("close this windows to stop plugIn");
		}


	}

	public void eventOccurred(int eventID) {
		switch (eventID) {
			case IJEventListener.LOG_WINDOW_CLOSED:
				IJ.removeEventListener(this);
				ImagePlus.removeImageListener(this);
				IJ.showStatus("Log window closed; EventListener stopped");
				break;
		}
	}
	// called when an image is opened
	public void imageOpened(ImagePlus imp) {
		IJ.log("Opened \""+imp.getTitle()+"\"");
		String nameCurrentImage=imp.getTitle();
		//delete extension file
		nameCurrentImage=nameCurrentImage.substring(0, nameCurrentImage.length()-4);
		//check if file is in the hashmap
		if(scale.containsKey(nameCurrentImage)){
			double currentScale=scale.get(nameCurrentImage);
			imp.unlock();
			IJ.run(imp,"Set Scale...", "known=1 distance="+currentScale+"  pixel=1 unit=cm");
			IJ.run("Scale Bar...", "width=50 color=White background=None location=[Lower Right] bold");
			IJ.log("scale : "+currentScale);
		}else{
			IJ.log("Wrong file, choose a file in scale file");
		}
	}

	// Called when an image is closed
	public void imageClosed(ImagePlus imp) {
		IJ.log("Closed \""+imp.getTitle()+"\"");
	}

	// Called when an image's pixel data is updated
	public void imageUpdated(ImagePlus imp) {
		/*nothing*/
	}
}
